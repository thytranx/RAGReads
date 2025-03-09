import os
import re
from dotenv import load_dotenv
from neo4j import GraphDatabase
from langchain.prompts import PromptTemplate
from langchain_openai import OpenAI
from langchain.chains import LLMChain 

import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sentence_transformers import SentenceTransformer

# Load environment variables
load_dotenv()

# Neo4j connection
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7690")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "Abhi@1234")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "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")

# Initialize embedding model
embedding_model = SentenceTransformer('all-MiniLM-L6-v2')

class BookGraphRAG:
    def __init__(self):
        self.driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
        self.llm = OpenAI(api_key=OPENAI_API_KEY, temperature=0.7)
        
    def close(self):
        self.driver.close()
        
    # -------------------- GRAPH-BASED INDEXING --------------------
    
    def get_book_graph_schema(self):
        """Get the schema of the book recommendation graph"""
        with self.driver.session() as session:
            result = session.run("""
                CALL db.schema.visualization()
            """)
            return result.data()
    
    # -------------------- GRAPH-GUIDED RETRIEVAL --------------------
    
    def retrieve_book_by_title(self, title):
        """Retrieve a book by its title"""
        with self.driver.session() as session:
            result = session.run("""
                MATCH (b:BOOK)
                WHERE b.BookTitle CONTAINS $title
                RETURN b
            """, title=title)
            return result.data()
    
    def retrieve_similar_books(self, book_title, n=3):
        """Retrieve books similar to the given book based on genre"""
        with self.driver.session() as session:
            result = session.run("""
                MATCH (b:BOOK {BookTitle: $book_title})-[:BELONGS_TO]->(g:GENRE)<-[:BELONGS_TO]-(similar:BOOK)
                WHERE similar.BookTitle <> $book_title
                RETURN similar.BookTitle AS similar_book, 
                       collect(g.Name) AS shared_genres,
                       count(g) AS genre_count
                ORDER BY genre_count DESC
                LIMIT $n
            """, book_title=book_title, n=n)
            return result.data()
            
    def retrieve_book_with_subgraph(self, book_title):
        """Retrieve a book with its 2-hop subgraph"""
        with self.driver.session() as session:
            result = session.run("""
                MATCH path = (b:BOOK {BookTitle: $book_title})-[*1..2]-(related)
                RETURN path
            """, book_title=book_title)
            
            # Process the result to extract nodes and relationships
            nodes = []  # Change from set to list
            relationships = []
            
            for record in result:
                path = record["path"]
                for node in path.nodes:
                    # Extract node info and create a hashable representation
                    node_info = {
                        'id': node.element_id,  # Use element_id instead of id
                        'label': list(node.labels)[0],
                        'properties': dict(node)
                    }
                    if node_info not in nodes:  # Manual duplicate check
                        nodes.append(node_info)
                        
                for rel in path.relationships:
                    # Create relationship info
                    rel_info = {
                        'type': rel.type,
                        'start_node': dict(rel.start_node),
                        'end_node': dict(rel.end_node),
                        'properties': dict(rel)
                    }
                    relationships.append(rel_info)
            
            return {
                "nodes": nodes,
                "relationships": relationships
            }
    
    def retrieve_user_recommendations(self, user_id, n=5):
        """Retrieve book recommendations for a user based on their reading history"""
        with self.driver.session() as session:
            # Get books that users with similar reading patterns have read
            result = session.run("""
                MATCH (u:USER {UserID: $user_id})-[r:READS]->(b:BOOK)-[:BELONGS_TO]->(g:GENRE)<-[:BELONGS_TO]-(rec:BOOK)
                WHERE NOT (u)-[:READS]->(rec)
                WITH rec, count(DISTINCT g) AS common_genres
                ORDER BY common_genres DESC
                LIMIT $n
                RETURN rec.BookTitle AS book_recommendation, 
                       rec.Description AS book_description
            """, user_id=user_id, n=n)
            return result.data()
    
    def retrieve_trending_books(self, limit=5):
        """Retrieve currently trending books based on recent reads"""
        with self.driver.session() as session:
            result = session.run("""
                MATCH (u:USER)-[r:READS]->(b:BOOK)
                WHERE r.StartDate >= '2024-01-01'
                WITH b, count(r) AS read_count
                ORDER BY read_count DESC
                LIMIT $limit
                RETURN b.BookTitle AS book, read_count
            """, limit=limit)
            return result.data()
    
    # -------------------- GRAPH FORMAT CONVERSION --------------------
    def convert_to_adjacency_table(self, subgraph):
        """Convert subgraph to adjacency table format"""
        adj_table = "Book Recommendation Graph - Adjacency Table:\n\n"
        
        # Group nodes by their label
        nodes_by_label = {}
        for node_info in subgraph["nodes"]:
            label = node_info['label']
            if label not in nodes_by_label:
                nodes_by_label[label] = []
            nodes_by_label[label].append(node_info['properties'])
        
        # Create adjacency table for each node type
        for label, nodes in nodes_by_label.items():
            adj_table += f"--- {label} Nodes ---\n"
            for node_props in nodes:
                node_name = node_props.get('BookTitle') or node_props.get('Name') or node_props.get('UserID') or str(node_props)
                adj_table += f"{node_name}: Connected to "
                
                # Find relationships for this node
                connections = []
                for rel in subgraph["relationships"]:
                    start_node = rel['start_node']
                    end_node = rel['end_node']
                    rel_type = rel['type']
                    
                    start_name = start_node.get('BookTitle') or start_node.get('Name') or start_node.get('UserID') or str(start_node)
                    end_name = end_node.get('BookTitle') or end_node.get('Name') or end_node.get('UserID') or str(end_node)
                    
                    if start_name == node_name:
                        connections.append(f"{end_name} ({rel_type})")
                    elif end_name == node_name:
                        connections.append(f"{start_name} ({rel_type})")
                
                adj_table += ", ".join(connections) + "\n"
            adj_table += "\n"
            
        return adj_table

    def convert_to_natural_language(self, subgraph):
        """Convert subgraph to natural language description"""
        nl_description = "Book Recommendation Graph - Natural Language Description:\n\n"
        
        # Extract book node if it exists
        book_node = None
        for node_info in subgraph["nodes"]:
            if node_info['label'] == "BOOK" and "BookTitle" in node_info['properties']:
                book_node = node_info['properties']
                break
        
        if book_node:
            nl_description += f"The book '{book_node['BookTitle']}' "
            
            # Find genres
            genres = []
            for rel in subgraph["relationships"]:
                if rel['type'] == "BELONGS_TO" and rel['start_node'].get('BookTitle') == book_node['BookTitle']:
                    genres.append(rel['end_node'].get('Name'))
            
            if genres:
                nl_description += f"belongs to the following genres: {', '.join(genres)}. "
            
            # Find author
            authors = []
            for rel in subgraph["relationships"]:
                if rel['type'] == "WROTE" and rel['end_node'].get('BookTitle') == book_node['BookTitle']:
                    authors.append(rel['start_node'].get('Name'))
            
            if authors:
                nl_description += f"It was written by {', '.join(authors)}. "
            
            # Find readers
            readers = []
            for rel in subgraph["relationships"]:
                if rel['type'] == "READS" and rel['end_node'].get('BookTitle') == book_node['BookTitle']:
                    readers.append(rel['start_node'].get('UserID'))
            
            if readers:
                nl_description += f"It has been read by {len(readers)} users. "
            
            # Find adaptations
            adaptations = []
            for rel in subgraph["relationships"]:
                if rel['type'] == "ADAPTS_TO" and rel['start_node'].get('BookTitle') == book_node['BookTitle']:
                    adaptations.append(rel['end_node'].get('Title'))
            
            if adaptations:
                nl_description += f"It has been adapted into: {', '.join(adaptations)}. "
                
            # Add book description if available
            if 'Description' in book_node:
                nl_description += f"\n\nDescription: {book_node['Description']}"
        
        return nl_description

    def convert_to_node_sequence(self, subgraph):
        """Convert subgraph to node sequence format"""
        sequence = "Book Recommendation Graph - Node Sequence:\n\n"
        
        # Find book node if it exists
        book_node = None
        for node_info in subgraph["nodes"]:
            if node_info['label'] == "BOOK" and "BookTitle" in node_info['properties']:
                book_node = node_info['properties']
                break
        
        if book_node:
            sequence += f"Start: {book_node['BookTitle']}\n"
            
            # Create paths from book to other related nodes
            paths = []
            for rel in subgraph["relationships"]:
                if rel['start_node'].get('BookTitle') == book_node['BookTitle']:
                    end_name = rel['end_node'].get('Name') or rel['end_node'].get('BookTitle') or rel['end_node'].get('UserID') or str(rel['end_node'])
                    paths.append(f"{book_node['BookTitle']} --[{rel['type']}]--> {end_name}")
                elif rel['end_node'].get('BookTitle') == book_node['BookTitle']:
                    start_name = rel['start_node'].get('Name') or rel['start_node'].get('BookTitle') or rel['start_node'].get('UserID') or str(rel['start_node'])
                    paths.append(f"{start_name} --[{rel['type']}]--> {book_node['BookTitle']}")
            
            sequence += "\n".join(paths)
        
        return sequence
    # -------------------- GRAPH-ENHANCED GENERATION --------------------
    
    def generate_book_recommendation(self, user_query, user_id=None):
        """Generate book recommendations based on user query and graph data"""
        
        # Step 1: Query enhancement - Expand the user query to extract key information
        expanded_query = self._enhance_query(user_query)
        
        # Step 2: Retrieve relevant information from the graph
        book_results = []
        # Extract potential book titles from the query
        book_titles = self._extract_book_titles(expanded_query)
        
        # If specific books were mentioned, retrieve their information
        for title in book_titles:
            book_data = self.retrieve_book_by_title(title)
            if book_data:
                book_results.extend(book_data)
                # Also retrieve similar books
                similar_books = self.retrieve_similar_books(book_data[0]['b']['BookTitle'])
                book_results.extend([{'similar': b} for b in similar_books])
        
        # If no specific books were mentioned or found, retrieve trending books
        if not book_results:
            trending_books = self.retrieve_trending_books()
            book_results.extend([{'trending': b} for b in trending_books])
        
        # If user ID is provided, also get personalized recommendations
        if user_id:
            user_recs = self.retrieve_user_recommendations(user_id)
            book_results.extend([{'recommended': r} for r in user_recs])
        
        # Step 3: Format graph data into natural language
        formatted_data = self._format_graph_data(book_results, expanded_query)
        
        # Step 4: Generate recommendation using LLM
        recommendation = self._generate_response(user_query, formatted_data)
        
        return {
            'original_query': user_query,
            'expanded_query': expanded_query,
            'retrieved_data': book_results,
            'recommendation': recommendation
        }
    
    def _enhance_query(self, query):
        """Enhance the user query to extract key information"""
        prompt = PromptTemplate(
            input_variables=["query"],
            template="""
            Given a user query about book recommendations, please expand it to include more details that would be helpful for a book recommendation system.
            Focus on extracting book titles, authors, genres, and user preferences.
            
            User Query: {query}
            
            Enhanced Query:
            """
        )
        
        chain = LLMChain(llm=self.llm, prompt=prompt)
        expanded_query = chain.run(query=query)
        return expanded_query
    
    def _extract_book_titles(self, query):
        """Extract potential book titles from the query"""
        # First try to find titles in quotes
        quoted_titles = re.findall(r'"([^"]*)"', query)
        if quoted_titles:
            return quoted_titles
        
        # Get books from the database to check against query
        with self.driver.session() as session:
            result = session.run("""
                MATCH (b:BOOK)
                RETURN b.BookTitle AS title
            """)
            all_titles = [record["title"] for record in result]
        
        # Check if any titles appear in the query
        mentioned_titles = []
        for title in all_titles:
            if title.lower() in query.lower():
                mentioned_titles.append(title)
        
        return mentioned_titles
    
    def _format_graph_data(self, book_results, query):
        """Format retrieved graph data into natural language"""
        formatted_text = "Book Information:\n\n"
        
        # Process books
        for item in book_results:
            if 'b' in item:  # Direct book result
                book = item['b']
                formatted_text += f"- {book['BookTitle']}\n"
                if 'Description' in book:
                    formatted_text += f"  Description: {book['Description']}\n"
                
                # Get book genres
                with self.driver.session() as session:
                    genres = session.run("""
                        MATCH (b:BOOK {BookTitle: $title})-[:BELONGS_TO]->(g:GENRE)
                        RETURN g.Name AS genre
                    """, title=book['BookTitle'])
                    genre_list = [record["genre"] for record in genres]
                
                if genre_list:
                    formatted_text += f"  Genres: {', '.join(genre_list)}\n"
                
                # Get book author
                with self.driver.session() as session:
                    author = session.run("""
                        MATCH (a:AUTHOR)-[:WROTE]->(b:BOOK {BookTitle: $title})
                        RETURN a.Name AS author
                    """, title=book['BookTitle'])
                    author_list = [record["author"] for record in author]
                
                if author_list:
                    formatted_text += f"  Author: {', '.join(author_list)}\n"
                
                formatted_text += "\n"
            
            elif 'similar' in item:  # Similar book
                similar = item['similar']
                formatted_text += f"- Similar to requested books: {similar['similar_book']}\n"
                formatted_text += f"  Shared genres: {', '.join(similar['shared_genres'])}\n\n"
            
            elif 'trending' in item:  # Trending book
                trending = item['trending']
                formatted_text += f"- Trending book: {trending['book']} (Read by {trending['read_count']} users recently)\n\n"
            
            elif 'recommended' in item:  # Recommended book
                rec = item['recommended']
                formatted_text += f"- Recommended for you: {rec['book_recommendation']}\n"
                if 'book_description' in rec and rec['book_description']:
                    formatted_text += f"  Description: {rec['book_description']}\n\n"
        
        return formatted_text
    
    def _generate_response(self, user_query, formatted_data):
        """Generate recommendation using LLM"""
        prompt = PromptTemplate(
            input_variables=["query", "book_data"],
            template="""
            You are a knowledgeable book recommendation assistant with expertise in literature and reader preferences.
            Based on the user's query and the retrieved book information, provide a helpful and engaging recommendation.
            
            Use the book information to support your recommendation, but feel free to be conversational and personalized.
            If multiple books are available, recommend the most relevant ones based on the user's query.
            
            User Query: {query}
            
            Book Information:
            {book_data}
            
            Your Recommendation:
            """
        )
        
        chain = LLMChain(llm=self.llm, prompt=prompt)
        response = chain.run(query=user_query, book_data=formatted_data)
        return response
    
    # -------------------- GENERATION ENHANCEMENT --------------------
    
    def pre_generation_enhancement(self, book_data):
        """Enhance the book data before generation"""
        # Extract common themes or patterns
        # For example, identify common genres, authors, or themes from the retrieved books
        genres = []
        authors = []
        
        for item in book_data:
            if 'b' in item and 'BookTitle' in item['b']:
                # Get book genres
                with self.driver.session() as session:
                    result = session.run("""
                        MATCH (b:BOOK {BookTitle: $title})-[:BELONGS_TO]->(g:GENRE)
                        RETURN g.Name AS genre
                    """, title=item['b']['BookTitle'])
                    genres.extend([record["genre"] for record in result])
                
                # Get book author
                with self.driver.session() as session:
                    result = session.run("""
                        MATCH (a:AUTHOR)-[:WROTE]->(b:BOOK {BookTitle: $title})
                        RETURN a.Name AS author
                    """, title=item['b']['BookTitle'])
                    authors.extend([record["author"] for record in result])
        
        # Count frequencies
        genre_counts = {}
        for genre in genres:
            genre_counts[genre] = genre_counts.get(genre, 0) + 1
        
        author_counts = {}
        for author in authors:
            author_counts[author] = author_counts.get(author, 0) + 1
        
        # Sort by frequency
        top_genres = sorted(genre_counts.items(), key=lambda x: x[1], reverse=True)[:3]
        top_authors = sorted(author_counts.items(), key=lambda x: x[1], reverse=True)[:3]
        
        enhancement = {
            'top_genres': [g[0] for g in top_genres],
            'top_authors': [a[0] for a in top_authors]
        }
        
        return enhancement
    
    def post_generation_enhancement(self, response, book_data):
        """Enhance the generated response"""
        # Add additional information or formatting to the response
        enhanced_response = response
        
        # Add trending books if not already included
        trending_mentioned = False
        for item in book_data:
            if 'trending' in item:
                trending_mentioned = True
                break
        
        if not trending_mentioned:
            trending_books = self.retrieve_trending_books(limit=3)
            if trending_books:
                enhanced_response += "\n\nYou might also be interested in these trending books:\n"
                for book in trending_books:
                    enhanced_response += f"- {book['book']}\n"
        
        return enhanced_response

# Example usage
def demo_graphrag_system():
    rag = BookGraphRAG()
    
    print("=== Book Recommendation GraphRAG System ===\n")
    
    # 1. Demonstrate Graph-Based Indexing
    print("1. GRAPH-BASED INDEXING")
    print("Getting graph schema...")
    schema = rag.get_book_graph_schema()
    print("Graph schema retrieved successfully\n")
    
    # 2. Demonstrate Graph-Guided Retrieval
    print("2. GRAPH-GUIDED RETRIEVAL")
    
    # Retrieve a specific book
    book_title = "Pride and Prejudice"
    print(f"Retrieving book: {book_title}")
    book = rag.retrieve_book_by_title(book_title)
    if book:
        print(f"Book found: {book[0]['b']['BookTitle']}")
    else:
        print("Book not found")
    
    # Retrieve similar books
    print("\nRetrieving similar books...")
    similar_books = rag.retrieve_similar_books(book_title)
    print("Similar books:")
    for book in similar_books:
        print(f"- {book['similar_book']} (Shared genres: {', '.join(book['shared_genres'])})")
    
    # Retrieve trending books
    print("\nRetrieving trending books...")
    trending = rag.retrieve_trending_books()
    print("Trending books:")
    for book in trending:
        print(f"- {book['book']} (Read count: {book['read_count']})")
    
    # 3. Demonstrate Graph Format Conversion
    print("\n3. GRAPH FORMAT CONVERSION")
    
    # Retrieve a book with its subgraph
    print(f"Retrieving subgraph for: {book_title}")
    subgraph = rag.retrieve_book_with_subgraph(book_title)
    
    # Convert to different formats
    print("\nConverting subgraph to different formats...")
    
    # Adjacency table
    adj_table = rag.convert_to_adjacency_table(subgraph)
    print("\nAdjacency Table format (excerpt):")
    print("\n".join(adj_table.split("\n")[:10]) + "\n...")
    
    # Natural language
    nl_description = rag.convert_to_natural_language(subgraph)
    print("\nNatural Language format (excerpt):")
    print("\n".join(nl_description.split("\n")[:5]) + "\n...")
    
    # Node sequence
    node_sequence = rag.convert_to_node_sequence(subgraph)
    print("\nNode Sequence format (excerpt):")
    print("\n".join(node_sequence.split("\n")[:5]) + "\n...")
    
    # 4. Demonstrate Graph-Enhanced Generation
    print("\n4. GRAPH-ENHANCED GENERATION")
    
    # Generate recommendation based on user query
    user_query = "I enjoy classic romance novels with strong female characters. Can you recommend something similar to Pride and Prejudice?"
    user_id = "5252680"  # Sarah's user ID
    
    print(f"User query: {user_query}")
    print(f"User ID: {user_id}")
    
    print("\nGenerating recommendation...")
    result = rag.generate_book_recommendation(user_query, user_id)
    
    print("\nExpanded query:")
    print(result['expanded_query'])
    
    print("\nRecommendation:")
    print(result['recommendation'])
    
    rag.close()

if __name__ == "__main__":
    demo_graphrag_system()
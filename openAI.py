from neo4j import GraphDatabase
import openai
import os

# Neo4j Connection Details
NEO4J_URI = "bolt://localhost:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "Abhi@1234"


class RAGApplication:
    def __init__(self, neo4j_uri, neo4j_user, neo4j_password):
        self.driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))

    def close(self):
        self.driver.close()

    def fetch_graph_data(self, query):
        with self.driver.session() as session:
            result = session.run(query)
            return [record["data"] for record in result]



    def query_openai(self, context, user_query):
        openai_api_key = "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"  # Replace with your actual key
        client = openai.OpenAI(api_key=openai_api_key)

     
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are an expert in book recommendations and user preferences."},
                {"role": "user", "content": f"Context: {context}\n\nQuestion: {user_query}"}
            ]
        )
        return response.choices[0].message.content  # Updated response format


    def run_rag_pipeline(self, user_query):
        query = """
        MATCH (u:User)-[r:RATED]->(b:Book) 
        RETURN u.name + ' rated ' + b.title + ' ' + r.rating + ' stars' AS data 
        LIMIT 5
        """
        graph_data = self.fetch_graph_data(query)
        
        if not graph_data:
            return "No relevant data found in the graph database."

        context = "\n".join(graph_data)
        openai_response = self.query_openai(context, user_query)
        
        return openai_response

if __name__ == "__main__":
    rag_app = RAGApplication(NEO4J_URI, NEO4J_USER, NEO4J_PASSWORD)
    
    user_query = "What can you tell me about book ratings and user preferences?"
    response = rag_app.run_rag_pipeline(user_query)
    
    print("AI Response:", response)
    
    rag_app.close()



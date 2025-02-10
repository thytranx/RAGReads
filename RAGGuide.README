
#  RAG Application with Neo4j & OpenAI

This repository demonstrates how to set up and run a Retrieval-Augmented Generation (RAG) application using Neo4j as a graph database and OpenAI's API for contextual recommendations.

## 🚀 Project Setup

### Step 1: Create and Activate a Virtual Environment

1. **Create a virtual environment**:
   ```bash
   python3 -m venv global_env
   ```

2. **Activate the virtual environment**:
   - **macOS/Linux**:
     ```bash
     source global_env/bin/activate
     ```
   - **Windows**:
     ```bash
     global_env\Scripts\activate
     ```

3. Verify the environment:
   ```bash
   which python
   ```

### Step 2: Install Dependencies

Inside the virtual environment, install required packages:
```bash
pip install neo4j openai python-dotenv
```

#### Dependencies
- `neo4j`: Connects to the Neo4j database.
- `openai`: Interacts with OpenAI's API.
- `python-dotenv`: Manages environment variables securely.

---

## 🔧 Setting Up Neo4j

1. **Install Neo4j Desktop**:
   - Download it from [Neo4j's official website](https://neo4j.com/download/).
   - Create a new project and a local database (version 5.x or later).
   - Set credentials: username = `neo4j`, password = `Abhi@1234`.


2. **Alternative Solutions**:

     Check If You Can Manually Log In
    To ensure your Neo4j database is accessible, follow these steps:
    
    - Open **Neo4j Browser**:  
       👉 [http://localhost:7474](http://localhost:7474)
       
    - Try logging in with the following credentials:
       - **Username**: `neo4j`
       - **Password**: `neo4j` (or the password you set)
    
    - **If login fails**, you may need to **reset your password**.


3. **Test Database Connection**:
   Open [Neo4j Browser](http://localhost:7474) and run:
   ```cypher
   MATCH (n) RETURN COUNT(n);
   ```

## 📌 Adding Sample Data

Use the following Cypher commands to populate the database with sample user, book, and rating data:

```cypher
// Create Users
CREATE (:User {id: 1, name: "Alice"});
CREATE (:User {id: 2, name: "Bob"});
CREATE (:User {id: 3, name: "Charlie"});

// Create Books
CREATE (:Book {id: 101, title: "The Great Gatsby", author: "F. Scott Fitzgerald"});
CREATE (:Book {id: 102, title: "1984", author: "George Orwell"});
CREATE (:Book {id: 103, title: "To Kill a Mockingbird", author: "Harper Lee"});

// Create Ratings
MATCH (u:User {id: 1}), (b:Book {id: 101}) CREATE (u)-[:RATED {rating: 5}]->(b);
MATCH (u:User {id: 1}), (b:Book {id: 102}) CREATE (u)-[:RATED {rating: 4}]->(b);
MATCH (u:User {id: 2}), (b:Book {id: 101}) CREATE (u)-[:RATED {rating: 3}]->(b);
MATCH (u:User {id: 2}), (b:Book {id: 103}) CREATE (u)-[:RATED {rating: 5}]->(b);
MATCH (u:User {id: 3}), (b:Book {id: 102}) CREATE (u)-[:RATED {rating: 2}]->(b);
MATCH (u:User {id: 3}), (b:Book {id: 103}) CREATE (u)-[:RATED {rating: 4}]->(b);
```

Verify:
```cypher
MATCH (u:User)-[r:RATED]->(b:Book) RETURN u.name, b.title, r.rating;
```

---

## 🤖 OpenAI Setup

1. **Generate an API key**:
   - Visit the [OpenAI platform](https://platform.openai.com/).
   - Create an API key and ensure you have sufficient credits.

2. **Add the key to your environment**:
   Use the `python-dotenv` library to securely manage your API key in a `.env` file:
   ```
   OPENAI_API_KEY=your_key_here
   ```

---

## ⚡ Writing the RAG Script

### Example: `openAI.py`

```python
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
```

---

## 🚀 Running the Application

1. Run the script:
   ```bash
   python openAI.py
   ```

2. Expected Output:
   - Data retrieved from Neo4j.
   - AI-generated recommendations printed to the console.

---

## ⚠️ Troubleshooting

- **RateLimitError (429)**:
  - Check OpenAI billing and quota.
  - Upgrade your plan if needed.
  - Implement a retry mechanism in your script.

Feel free to adapt this structure for your README file. Let me know if you'd like further refinements!

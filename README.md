# RAGReads
RAGReads is a GraphDB-powered book recommendation app that utilizes a Graph-based Retrieval-Augmented Generation (RAG) model. It analyzes book relationships to suggest personalized reading recommendations, enhancing discovery with AI-driven insights from interconnected data for an enriched reading experience.

# RAGReads 📚🔍  
**Graph-Powered Book Recommendation Engine with LLM Insights**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-green.svg)](https://www.python.org/)
[![Neo4j](https://img.shields.io/badge/GraphDB-Neo4j-008CC1.svg)](https://neo4j.com/)

RagReads combines graph database relationships with large language models to deliver contextual book recommendations through semantic understanding of user preferences and literary content.

![RagReads Architecture](assets/ragreads-arch.png)
    
## 🌟 Features

### **Graph RAG Engine**
- 📊 Neo4j knowledge graph with 50+ relationship types
- 🔗 Context-aware node connections (GENRE, AUTHOR_STYLE, THEMATIC_SIMILARITY)
- 🧠 User preference vector embeddings (768d)

### **LLM Integration**
- 📚 GPT-4 for content understanding & summary generation
- 🤖 Custom fine-tuned recommendation model (LoRA adapters)
- 🎯 Semantic similarity scoring with Sentence-BERT

### **Core Capabilities**
- Personalized reading lists based on graph walks
- "Why Recommended" explainable AI feature
- Multi-hop relationship discovery
- Real-time graph updates from user feedback

## 🚀 Installation

```bash
# Clone repository
git clone https://github.com/yourusername/RagReads.git
cd RagReads

# Install dependencies
pip install -r requirements.txt

# Set up environment
cp .env.example .env
# Update Neo4j and OpenAI credentials in .env

# Initialize graph database
python scripts/init_graph.py

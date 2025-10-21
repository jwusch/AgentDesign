"""
RAG (Retrieval-Augmented Generation) Engine
Handles embeddings, vector storage, and context retrieval
"""

import os
import ollama
from typing import List, Dict, Optional
from sentence_transformers import SentenceTransformer
import chromadb
from chromadb.config import Settings
import uuid


class RAGEngine:
    """RAG engine for document question answering"""

    def __init__(
        self,
        model_name: str = "llama3",
        embedding_model: str = "all-MiniLM-L6-v2",
        collection_name: str = "papers"
    ):
        """
        Initialize RAG engine

        Args:
            model_name: Ollama model to use for generation
            embedding_model: Sentence transformer model for embeddings
            collection_name: ChromaDB collection name
        """
        self.model_name = model_name
        self.embedding_model_name = embedding_model

        # Initialize embedding model
        print(f"Loading embedding model: {embedding_model}")
        self.embedder = SentenceTransformer(embedding_model)

        # Initialize ChromaDB
        self.chroma_client = chromadb.Client(Settings(
            anonymized_telemetry=False,
            allow_reset=True
        ))

        # Create or get collection
        self.collection = self.chroma_client.get_or_create_collection(
            name=collection_name,
            metadata={"description": "Research papers collection"}
        )

        print(f"RAG Engine initialized with model: {model_name}")

    def add_documents(self, chunks: List[str], metadata: Optional[Dict] = None) -> None:
        """
        Add document chunks to vector store

        Args:
            chunks: List of text chunks
            metadata: Optional metadata for the chunks
        """
        print(f"Adding {len(chunks)} chunks to vector store...")

        # Generate embeddings
        embeddings = self.embedder.encode(chunks, show_progress_bar=True)

        # Prepare documents for ChromaDB
        ids = [str(uuid.uuid4()) for _ in chunks]
        metadatas = [metadata or {} for _ in chunks]

        # Add to collection
        self.collection.add(
            ids=ids,
            embeddings=embeddings.tolist(),
            documents=chunks,
            metadatas=metadatas
        )

        print(f"Successfully added {len(chunks)} chunks")

    def retrieve_context(self, query: str, n_results: int = 3) -> List[str]:
        """
        Retrieve relevant context for a query

        Args:
            query: User question
            n_results: Number of chunks to retrieve

        Returns:
            List of relevant text chunks
        """
        # Generate query embedding
        query_embedding = self.embedder.encode([query])[0]

        # Search in vector store
        results = self.collection.query(
            query_embeddings=[query_embedding.tolist()],
            n_results=n_results
        )

        # Extract documents
        if results['documents']:
            return results['documents'][0]
        return []

    def generate_response(
        self,
        query: str,
        context: List[str],
        conversation_history: Optional[List[Dict]] = None
    ) -> str:
        """
        Generate response using Ollama with retrieved context

        Args:
            query: User question
            context: Retrieved context chunks
            conversation_history: Previous conversation messages

        Returns:
            Generated response
        """
        # Build context string
        context_text = "\n\n".join(context)

        # Build system prompt
        system_prompt = f"""You are a helpful AI assistant specialized in analyzing research papers.
Use the following context from the paper to answer the user's question. If the answer is not in the context,
say so honestly. Be concise but thorough.

Context from the paper:
{context_text}
"""

        # Build messages
        messages = [{"role": "system", "content": system_prompt}]

        # Add conversation history if provided
        if conversation_history:
            messages.extend(conversation_history)

        # Add current query
        messages.append({"role": "user", "content": query})

        # Generate response using Ollama
        try:
            response = ollama.chat(
                model=self.model_name,
                messages=messages
            )
            return response['message']['content']

        except Exception as e:
            return f"Error generating response: {str(e)}"

    def chat(
        self,
        query: str,
        conversation_history: Optional[List[Dict]] = None,
        n_context: int = 3
    ) -> Dict[str, any]:
        """
        Complete RAG chat pipeline

        Args:
            query: User question
            conversation_history: Previous conversation
            n_context: Number of context chunks to retrieve

        Returns:
            Response dict with answer and sources
        """
        # Retrieve relevant context
        context = self.retrieve_context(query, n_results=n_context)

        # Generate response
        answer = self.generate_response(query, context, conversation_history)

        return {
            "answer": answer,
            "sources": context,
            "n_sources": len(context)
        }

    def clear_collection(self) -> None:
        """Clear all documents from collection"""
        self.chroma_client.delete_collection(self.collection.name)
        self.collection = self.chroma_client.get_or_create_collection(
            name=self.collection.name
        )
        print("Collection cleared")

    def get_collection_count(self) -> int:
        """Get number of documents in collection"""
        return self.collection.count()


if __name__ == "__main__":
    # Test the RAG engine
    print("Testing RAG Engine...")
    rag = RAGEngine()
    print(f"Collection has {rag.get_collection_count()} documents")

"""
Flask API Server for arXiv Paper Chat
Provides REST endpoints for PDF upload, processing, and chatting
"""

import os
import tempfile
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
from pdf_processor import PDFProcessor
from rag_engine import RAGEngine

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend communication

# Configuration
UPLOAD_FOLDER = tempfile.gettempdir()
ALLOWED_EXTENSIONS = {'pdf'}
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

# Initialize components
pdf_processor = PDFProcessor(chunk_size=1000, chunk_overlap=200)
rag_engine = None  # Will be initialized after PDF upload

# Store conversation history per session
conversations = {}


def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "message": "arXiv Paper Chat API is running"
    })


@app.route('/api/upload', methods=['POST'])
def upload_pdf():
    """
    Upload and process PDF file
    Returns the number of chunks created
    """
    global rag_engine

    # Check if file is present
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']

    # Check if file is selected
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400

    # Validate file
    if not allowed_file(file.filename):
        return jsonify({"error": "Only PDF files are allowed"}), 400

    try:
        # Save uploaded file
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # Process PDF
        print(f"Processing PDF: {filename}")
        chunks = pdf_processor.process_pdf(filepath)

        # Initialize RAG engine with new collection
        collection_name = f"paper_{filename.replace('.pdf', '')}"
        rag_engine = RAGEngine(
            model_name="llama3",
            collection_name=collection_name
        )

        # Add chunks to vector store
        metadata = {"filename": filename}
        rag_engine.add_documents(chunks, metadata)

        # Clean up uploaded file
        os.remove(filepath)

        return jsonify({
            "success": True,
            "filename": filename,
            "chunks": len(chunks),
            "message": f"Successfully processed {len(chunks)} chunks from {filename}"
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/chat', methods=['POST'])
def chat():
    """
    Chat endpoint - accepts question and returns AI response
    """
    global rag_engine

    if rag_engine is None:
        return jsonify({"error": "Please upload a PDF first"}), 400

    data = request.json

    if not data or 'message' not in data:
        return jsonify({"error": "No message provided"}), 400

    message = data['message']
    session_id = data.get('session_id', 'default')

    # Get or create conversation history
    if session_id not in conversations:
        conversations[session_id] = []

    try:
        # Get response from RAG engine
        response = rag_engine.chat(
            query=message,
            conversation_history=conversations[session_id],
            n_context=3
        )

        # Update conversation history
        conversations[session_id].append({"role": "user", "content": message})
        conversations[session_id].append({"role": "assistant", "content": response['answer']})

        return jsonify({
            "success": True,
            "answer": response['answer'],
            "sources": response['sources'],
            "n_sources": response['n_sources']
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/clear', methods=['POST'])
def clear_conversation():
    """Clear conversation history for a session"""
    data = request.json
    session_id = data.get('session_id', 'default')

    if session_id in conversations:
        conversations[session_id] = []

    return jsonify({"success": True, "message": "Conversation cleared"})


@app.route('/api/reset', methods=['POST'])
def reset():
    """Reset everything - clear collection and conversations"""
    global rag_engine, conversations

    if rag_engine:
        rag_engine.clear_collection()
        rag_engine = None

    conversations = {}

    return jsonify({"success": True, "message": "System reset"})


@app.route('/api/status', methods=['GET'])
def status():
    """Get current system status"""
    return jsonify({
        "pdf_loaded": rag_engine is not None,
        "chunks_count": rag_engine.get_collection_count() if rag_engine else 0,
        "active_sessions": len(conversations)
    })


if __name__ == '__main__':
    print("=" * 60)
    print("arXiv Paper Chat - Local Backend Server")
    print("=" * 60)
    print("\nStarting server...")
    print("Make sure Ollama is running with llama3 model:")
    print("  ollama pull llama3")
    print("  ollama serve")
    print("\nServer will be available at: http://localhost:5000")
    print("=" * 60)

    app.run(debug=True, host='0.0.0.0', port=5000)

# arXiv Paper Chat

A beautiful, interactive web application for browsing AI research papers from arXiv and chatting with them using AI-powered PDF chatbots.

## Versions Available

### Local Edition (Recommended - Privacy First!)
Run everything on your own machine with complete privacy. Uses Ollama for local LLM inference and RAG for accurate answers.

- **File**: `index.html` - Local version with Python backend
- **Privacy**: All processing happens locally - no external API calls
- **Cost**: Completely free - no API costs
- **Models**: Use any Ollama model (llama3, mistral, etc.)

### Cloud Edition
Uses HuggingFace Spaces for chatbot functionality (requires internet).

- **File**: `index-cloud.html` - Cloud version
- **Convenience**: No setup required, just open in browser
- **Dependency**: Requires HuggingFace services to be online

## Features

### Local Edition
- **Complete Privacy**: All data stays on your machine
- **RAG-Powered**: Advanced Retrieval-Augmented Generation for accurate answers
- **Vector Embeddings**: Uses ChromaDB for semantic search
- **Source Citations**: Shows relevant paper sections used for each answer
- **Conversation History**: Maintains context across questions
- **PDF Processing**: Automatic text extraction and intelligent chunking

### Both Versions
- **Browse Research Papers**: Curated collection of cutting-edge AI research papers organized by category
  - LLM Reasoning & Training
  - AI Safety & Alignment
  - Vision-Language Models
- **Select Papers**: Choose from various influential papers with detailed descriptions
- **Download PDFs**: Direct links to arXiv papers
- **Integrated Experience**: Seamlessly download papers and chat with them

## Setup Instructions

### Local Edition Setup

**Prerequisites:**
- Python 3.8 or higher
- Ollama installed on your system

**Step 1: Install Ollama**
```bash
# macOS/Linux
curl -fsSL https://ollama.com/install.sh | sh

# Or download from https://ollama.com
```

**Step 2: Pull an LLM Model**
```bash
# Recommended: Llama 3 (4.7GB)
ollama pull llama3

# Alternatives:
# ollama pull mistral       # Smaller, faster
# ollama pull llama2        # Older but reliable
# ollama pull codellama     # Good for technical papers
```

**Step 3: Install Python Dependencies**
```bash
cd backend
pip install -r requirements.txt
```

**Step 4: Start the Backend Server**
```bash
cd backend
python server.py
```

The server will start on `http://localhost:5000`

**Step 5: Open the Frontend**
```bash
# In a new terminal, from the project root
python -m http.server 8000
```

Then open `http://localhost:8000` in your browser.

### Cloud Edition Setup

No setup required! Simply open `index-cloud.html` in your browser.

## How to Use (Local Edition)

1. **Start Backend**: Make sure the Python backend is running (`python backend/server.py`)
2. **Open Frontend**: Navigate to `http://localhost:8000` in your browser
3. **Browse Papers**: Explore the curated collection of AI research papers
4. **Download PDF**: Click "Download PDF" on any paper that interests you
5. **Open Chat**: Click "Open Chat Interface"
6. **Upload PDF**: Click "Upload PDF" and select the downloaded paper
7. **Ask Questions**: Start chatting! The AI will answer based on the paper content
8. **View Sources**: Expand source sections to see which parts of the paper were used

## Technology Stack

### Frontend
- **React 18**: Modern UI framework
- **Tailwind CSS**: Beautiful, responsive styling
- **Babel Standalone**: In-browser JSX compilation

### Backend (Local Edition)
- **Flask**: Lightweight Python web framework
- **Ollama**: Local LLM inference
- **LangChain**: LLM application framework
- **ChromaDB**: Vector database for embeddings
- **Sentence Transformers**: Text embedding generation
- **PyPDF2**: PDF text extraction

## Featured Papers

### LLM Reasoning & Training
- LightReasoner - Training large models using small models
- BoostStep - Mathematical reasoning enhancement
- Impact of Reasoning Step Length
- Divide and Conquer strategies
- Reverse Curriculum RL

### AI Safety & Alignment
- Comprehensive survey of alignment techniques
- Constitutional AI and DPO methods

### Vision-Language Models
- AlignVLM - Bridging vision and language
- DeepSeek-VL2 - Mixture-of-Experts approach
- Vision-Language-Action Models
- Chart Understanding with MMC

## API Endpoints (Local Backend)

The Flask backend provides the following REST API endpoints:

- `GET /api/health` - Health check
- `GET /api/status` - Get system status (PDF loaded, chunk count)
- `POST /api/upload` - Upload and process a PDF file
- `POST /api/chat` - Send a message and get AI response
- `POST /api/clear` - Clear conversation history
- `POST /api/reset` - Reset system (clear all data)

## Architecture

```
┌─────────────────┐
│   Frontend      │  React SPA
│   (index.html)  │  - Browse papers
│                 │  - Upload PDF
└────────┬────────┘  - Chat interface
         │
         │ HTTP/REST
         ▼
┌─────────────────┐
│  Flask API      │  Python Backend
│  (server.py)    │  - PDF upload
└────────┬────────┘  - Request routing
         │
    ┌────┴────┐
    ▼         ▼
┌─────────┐ ┌──────────┐
│   PDF   │ │   RAG    │
│Processor│ │  Engine  │
└─────────┘ └────┬─────┘
                 │
        ┌────────┴────────┐
        ▼                 ▼
   ┌─────────┐      ┌─────────┐
   │ChromaDB │      │ Ollama  │
   │Vectors  │      │  LLM    │
   └─────────┘      └─────────┘
```

## Customization

### Change the LLM Model

Edit `backend/rag_engine.py` and change the model name:

```python
rag_engine = RAGEngine(
    model_name="mistral",  # Change this
    embedding_model="all-MiniLM-L6-v2"
)
```

### Adjust Chunk Size

Edit `backend/pdf_processor.py`:

```python
processor = PDFProcessor(
    chunk_size=1500,  # Increase for more context
    chunk_overlap=300  # Increase for better continuity
)
```

### Change Number of Retrieved Chunks

Edit `backend/server.py` in the chat endpoint:

```python
response = rag_engine.chat(
    query=message,
    conversation_history=conversations[session_id],
    n_context=5  # Retrieve more chunks
)
```

## Troubleshooting

### Backend won't start
- Make sure all dependencies are installed: `pip install -r backend/requirements.txt`
- Check if port 5000 is available: `lsof -i :5000`
- Ensure Ollama is running: `ollama list`

### "Ollama connection error"
- Start Ollama service: `ollama serve`
- Pull the model: `ollama pull llama3`
- Check Ollama is running: `curl http://localhost:11434`

### Slow responses
- Try a smaller model: `ollama pull mistral`
- Reduce context chunks in `server.py` (change `n_context` to 2)
- Consider using GPU acceleration for Ollama

### PDF upload fails
- Check file size (max 50MB)
- Ensure PDF is not password protected
- Try a different PDF

## Performance Tips

1. **GPU Acceleration**: Ollama automatically uses GPU if available (NVIDIA, Apple Silicon)
2. **Model Selection**: Smaller models (mistral) are faster, larger models (llama3) are more accurate
3. **Chunk Tuning**: Balance between chunk_size (more context) and response time
4. **Embeddings**: The `all-MiniLM-L6-v2` model is fast and lightweight. For better quality, try `all-mpnet-base-v2`

## Deployment

### Cloud Edition
Deploy the static HTML file anywhere:
- **GitHub Pages**: Just commit and enable GitHub Pages
- **Netlify**: Drag and drop `index-cloud.html`
- **Vercel**: Deploy with zero configuration

### Local Edition
For production deployment:
- Use **Gunicorn** instead of Flask dev server
- Add **nginx** as reverse proxy
- Consider **Docker** for easy deployment
- Set up **systemd** service for auto-start

## License

This project is open source and available for educational purposes.

## Credits

- Local AI powered by Ollama
- Cloud chatbots powered by HuggingFace Spaces
- Papers sourced from arXiv
- Icons inspired by Lucide Icons
- RAG implementation using LangChain and ChromaDB

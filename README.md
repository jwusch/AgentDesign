# arXiv Paper Chat

A beautiful, interactive web application for browsing AI research papers from arXiv and chatting with them using AI-powered PDF chatbots.

## Features

- **Browse Research Papers**: Curated collection of cutting-edge AI research papers organized by category
  - LLM Reasoning & Training
  - AI Safety & Alignment
  - Vision-Language Models

- **Select Papers**: Choose from various influential papers with detailed descriptions
- **AI Chatbots**: Two powerful chatbot options to analyze your papers:
  - **PDF Chatbot** by cvachet (369 likes) - Simple and effective
  - **RAG PDF Chatbot** by MuntasirHossain (68 likes) - Advanced RAG-based analysis

- **Integrated Experience**: Seamlessly download papers and chat with them in one interface

## How to Use

1. **Browse Papers**: Start by exploring the paper categories on the main page
2. **Select a Paper**: Click "Select" on any paper that interests you
3. **Choose a Chatbot**: Click "Proceed to Select Chatbot" and pick your preferred AI assistant
4. **Download PDF**: Download the paper PDF from the paper card
5. **Start Chatting**: Upload the PDF to the chatbot and ask questions about the research!

## Technology Stack

- **React 18**: Modern UI framework
- **Tailwind CSS**: Beautiful, responsive styling
- **Babel Standalone**: In-browser JSX compilation
- **Hugging Face Spaces**: Integrated chatbot services

## Running the Application

Simply open `index.html` in any modern web browser. No build process or dependencies required!

```bash
# Using Python's built-in server
python -m http.server 8000

# Using Node.js http-server
npx http-server

# Or just open the file directly
open index.html
```

Then navigate to `http://localhost:8000` in your browser.

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

## Deployment

This is a static HTML file that can be deployed anywhere:

- **GitHub Pages**: Just commit and enable GitHub Pages
- **Netlify**: Drag and drop the HTML file
- **Vercel**: Deploy with zero configuration
- **Any static hosting**: Works everywhere!

## License

This project is open source and available for educational purposes.

## Credits

- Chatbots powered by Hugging Face Spaces
- Papers sourced from arXiv
- Icons inspired by Lucide Icons

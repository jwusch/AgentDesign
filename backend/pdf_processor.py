"""
PDF Processing Module
Handles PDF text extraction and chunking for RAG
"""

import os
from typing import List
from PyPDF2 import PdfReader


class PDFProcessor:
    """Process PDF files and extract text in chunks"""

    def __init__(self, chunk_size: int = 1000, chunk_overlap: int = 200):
        """
        Initialize PDF processor

        Args:
            chunk_size: Size of text chunks in characters
            chunk_overlap: Overlap between chunks for context continuity
        """
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap

    def extract_text(self, pdf_path: str) -> str:
        """
        Extract all text from PDF

        Args:
            pdf_path: Path to PDF file

        Returns:
            Extracted text as string
        """
        try:
            reader = PdfReader(pdf_path)
            text = ""

            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"

            return text.strip()

        except Exception as e:
            raise Exception(f"Error extracting text from PDF: {str(e)}")

    def chunk_text(self, text: str) -> List[str]:
        """
        Split text into overlapping chunks

        Args:
            text: Text to chunk

        Returns:
            List of text chunks
        """
        chunks = []
        start = 0
        text_length = len(text)

        while start < text_length:
            # Calculate end position
            end = start + self.chunk_size

            # Find the last complete sentence or paragraph in chunk
            if end < text_length:
                # Look for sentence ending
                for punct in ['. ', '.\n', '! ', '!\n', '? ', '?\n']:
                    last_punct = text[start:end].rfind(punct)
                    if last_punct != -1:
                        end = start + last_punct + len(punct)
                        break

            # Add chunk
            chunk = text[start:end].strip()
            if chunk:
                chunks.append(chunk)

            # Move start position with overlap
            start = end - self.chunk_overlap if end < text_length else text_length

        return chunks

    def process_pdf(self, pdf_path: str) -> List[str]:
        """
        Complete PDF processing pipeline

        Args:
            pdf_path: Path to PDF file

        Returns:
            List of text chunks
        """
        text = self.extract_text(pdf_path)
        chunks = self.chunk_text(text)
        return chunks


if __name__ == "__main__":
    # Test the processor
    processor = PDFProcessor()
    print("PDF Processor initialized successfully")

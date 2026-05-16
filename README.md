# Docmind

AI-powered conversational document assistant built using Flutter, FastAPI, Supabase, and OpenAI GPT-4o.

Upload a PDF and have a real conversation with it using semantic retrieval, streaming AI responses, and optimized context management.

---

## Features

* Conversational AI over PDFs
* Streaming GPT-4o responses
* Semantic document retrieval
* Page-aware AI responses
* Persistent multi-session chat history
* PDF export support
* Cross-platform Flutter frontend
* Row Level Security using Supabase
* Token-optimized context management
* Parallel embedding pipeline for faster uploads

## Preview

<p align="center">
  <img src="assets/screenshots/ai_response.jpg" width="320"/>
</p>

## Architecture Overview

Docmind follows a production-style AI architecture with a cross-platform Flutter frontend, FastAPI backend, semantic retrieval pipeline, and GPT-4o streaming responses.

### Frontend (Flutter)

* Single codebase for Android, iOS, and Web
* BLoC state management architecture
* go_router navigation system
* Responsive and adaptive UI
* Supabase authentication integration

### Backend (FastAPI)

* PDF ingestion and processing pipeline
* Semantic chunk retrieval system
* Streaming AI response orchestration
* Context summarization and token optimization
* Parallel embedding generation

### Database & Security (Supabase)

* Persistent chat sessions and messages
* Secure document metadata storage
* Row Level Security (RLS) enforcement
* Authenticated user isolation

### AI Pipeline (OpenAI GPT-4o)

* Embedding-based semantic retrieval
* Context-aware response generation
* Streaming token responses
* Page-aware answer references

## Performance Optimizations

Docmind includes several production-focused optimizations designed to improve performance, reduce AI costs, and maintain scalable conversations.

### Token Optimization

Implemented rolling conversation summarization to reduce token usage by approximately 70% while preserving conversational context.

### Parallel Embedding Pipeline

Document chunks are processed concurrently, reducing upload and embedding generation time by approximately 80%.

### Streaming AI Responses

Responses are streamed token-by-token to improve perceived responsiveness and conversational UX.

### Semantic Retrieval

Only the most relevant document chunks are sent to GPT-4o, reducing unnecessary context size and improving answer quality.

### Context Window Management

Older messages are intelligently summarized to prevent context overflow during long-running conversations.

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter |
| State Management | flutter_bloc |
| Navigation | go_router |
| Backend | FastAPI |
| Database | Supabase |
| Authentication | Supabase Auth |
| AI | OpenAI GPT-4o |
| Hosting | Render + Firebase Hosting |
| PDF Processing | PyPDF |
| Export Engine | ReportLab |

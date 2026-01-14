#!/bin/bash
# Start both backend and frontend for local development

echo "🚀 Starting HabitKit Clone Development Servers..."
echo ""

# Function to cleanup on exit
cleanup() {
  echo ""
  echo "🛑 Stopping servers..."
  kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
  exit
}

trap cleanup SIGINT SIGTERM

# Start backend
echo "📦 Starting Rails backend on port 3001..."
cd backend
bundle exec rails server -b 0.0.0.0 -p 3001 > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Wait a bit for backend to start
sleep 2

# Start frontend
echo "⚛️  Starting React frontend on port 5173..."
cd frontend
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ Servers started!"
echo ""
echo "📍 Local:"
echo "   Frontend: http://localhost:5173"
echo "   Backend GraphQL: http://localhost:3001/graphql"
echo "   GraphiQL IDE: http://localhost:3001/graphiql"
echo ""
echo "📱 Network (for phone access):"
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "IP not found")
echo "   Frontend: http://$LOCAL_IP:5173"
echo "   Backend GraphQL: http://$LOCAL_IP:3001/graphql"
echo ""
echo "📝 Logs:"
echo "   Backend: tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Wait for both processes
wait

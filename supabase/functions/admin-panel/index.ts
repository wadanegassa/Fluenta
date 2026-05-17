import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const html = `
<!DOCTYPE html>
<html>
<head>
  <title>Fluenta Admin Panel</title>
  <style>
    body { font-family: sans-serif; padding: 20px; background: #f4f4f9; color: #333; }
    h1, h2 { color: #1e1e24; }
    .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
    button { background: #d9534f; color: white; border: none; padding: 10px 15px; border-radius: 4px; cursor: pointer; }
    button:hover { background: #c9302c; }
    .btn-clear { background: #f0ad4e; }
    .btn-clear:hover { background: #ec971f; }
    input { padding: 8px; margin-right: 10px; width: 300px; border: 1px solid #ccc; border-radius: 4px; }
    pre { background: #333; color: #fff; padding: 10px; border-radius: 4px; overflow-x: auto; }
  </style>
</head>
<body>
  <h1>Fluenta Admin Panel</h1>
  
  <div class="card">
    <h2>Delete User</h2>
    <p>Warning: This will permanently delete the user and cascade delete their profile data if configured.</p>
    <form id="deleteUserForm">
      <input type="text" id="userId" placeholder="User ID (UUID)" required>
      <button type="submit">Delete User</button>
    </form>
  </div>

  <div class="card">
    <h2>Clear Table Data</h2>
    <p>Type the exact name of the table to delete all rows from it (e.g., profiles, modules, lessons, user_lesson_progress, messages).</p>
    <form id="clearTableForm">
      <input type="text" id="tableName" placeholder="Table Name" required>
      <button type="submit" class="btn-clear">Delete All Rows</button>
    </form>
  </div>

  <div class="card">
    <h2>Output</h2>
    <pre id="output">Waiting for action...</pre>
  </div>

  <script>
    async function performAction(action, payload) {
      const out = document.getElementById('output');
      out.textContent = 'Processing...';
      
      try {
        // Need to hit current endpoint
        const currentUrl = window.location.href;
        const res = await fetch(currentUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, ...payload })
        });
        const data = await res.json();
        out.textContent = JSON.stringify(data, null, 2);
      } catch (err) {
        out.textContent = 'Error: ' + err.message;
      }
    }

    document.getElementById('deleteUserForm').addEventListener('submit', (e) => {
      e.preventDefault();
      const id = document.getElementById('userId').value;
      if (confirm('Are you absolutely sure you want to delete user ' + id + '?')) {
        performAction('delete_user', { id });
      }
    });

    document.getElementById('clearTableForm').addEventListener('submit', (e) => {
      e.preventDefault();
      const table = document.getElementById('tableName').value;
      if (confirm('Are you absolutely sure you want to DELETE ALL DATA from ' + table + '?')) {
        performAction('clear_table', { table });
      }
    });
  </script>
</body>
</html>
`;

serve(async (req) => {
  const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
  const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  // Handle GET request to serve HTML
  if (req.method === 'GET') {
    return new Response(html, {
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
    });
  }

  // Handle POST requests for admin actions
  if (req.method === 'POST') {
    try {
      const body = await req.json();
      const { action } = body;

      if (action === 'delete_user') {
        const { id } = body;
        const { data, error } = await supabase.auth.admin.deleteUser(id);
        if (error) throw error;
        return new Response(JSON.stringify({ success: true, message: `User ${id} deleted successfully`, data }), {
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
          }
        });
      }

      if (action === 'clear_table') {
        const { table } = body;
        
        let col = 'id';
        if (table === 'user_lesson_progress' || table === 'user_skill_progress') {
            col = 'user_id';
        }

        const { data, error } = await supabase.from(table).delete().not(col, 'is', null);
        
        if (error) throw error;
        return new Response(JSON.stringify({ success: true, message: `All rows deleted from ${table}`, data }), {
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
          }
        });
      }

      return new Response(JSON.stringify({ error: 'Unknown action' }), { status: 400 });

    } catch (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }
  }

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type' } })
  }

  return new Response('Method not allowed', { status: 405 });
});

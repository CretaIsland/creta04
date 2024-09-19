// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
//import { createClient } from '@supabase/supabase-js';
import { createClient } from 'https://cdn.skypack.dev/@supabase/supabase-js';

console.log("executeSQL function loaded");

Deno.serve(async (req) => {
  try {
    console.log("executeSQL 1");
    console.log("Request Method:", req.method);
    console.log("Request URL:", req.url);
// Headers 객체를 배열로 변환하여 출력
    const headersArray = [];
    for (const [key, value] of req.headers.entries()) {
      headersArray.push({ key, value });
    }
    console.log("Request Headers:", JSON.stringify(headersArray));


    // CORS 처리
    if (req.method === "OPTIONS") {
      console.log("OPTIONS 요청 처리");
      return new Response(null, {
        status: 204,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          //"Access-Control-Allow-Headers": "Content-Type, Authorization",
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          "Access-Control-Max-Age": "3600", // 1시간 동안 프리플라이트 요청 결과를 캐시
        },
      });
    }
    
    console.log("executeSQL 1.1");

    const { endPoint, apiKey, roleKey, sql } = await req.json();
    console.log("executeSQL 2");

    // Ensure the SQL query, endPoint, and apiKey are provided
    if (!sql || !endPoint || !apiKey || !roleKey) {
      return new Response(
        JSON.stringify({ error: "SQL query, endPoint, or apiKey not provided" }),
        { status: 400, headers: { 
          'Access-Control-Allow-Origin' : '*',
          "Content-Type": "application/json" } },
      );
    }

    // Execute the SQL query using Supabase client
    console.log("executeSQL endPoint: ", endPoint);
    console.log("executeSQL apiKey: ", apiKey);
    console.log("executeSQL roleKey: ", roleKey);
    const client = createClient(endPoint, roleKey || apiKey);
    console.log("executeSQL sql: ", sql);

    const { data, error } = await client.rpc('execute_sql', { sql });
    console.log("executeSQL 5");

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { 
          'Access-Control-Allow-Origin' : '*',
          "Content-Type": "application/json" } },
      );
    }
    console.log("executeSQL 6");

    return new Response(
      JSON.stringify(data),
      { status: 200, headers: { 
        'Access-Control-Allow-Origin': '*',
        "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { 
        'Access-Control-Allow-Origin' : '*',
        "Content-Type": "application/json" } },
    );
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/v1/executeSQL' \
    --header 'Authorization: Bearer YOUR_SUPABASE_ANON_KEY' \
    --header 'Content-Type: application/json' \
    --data '{"sql":"SELECT * FROM your_table", "endPoint":"https://your-project.supabase.co", "apiKey":"your-anon-key"}'

*/
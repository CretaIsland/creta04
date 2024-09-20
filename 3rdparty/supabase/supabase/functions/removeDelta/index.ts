// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs

////////////////////////////////////////////////////////
// scheduling SQL query execution every minute
// SQL Editor 에서 작업할것   memo.txt 8번항 참고할것.
// 
//////////////////////////////////////////////////////// 
/* 
select
  cron.schedule(
    'invoke-removeDelta-every-minute',
    '* * * * *', -- every minute
    $$
    select
      net.http_post(
          url:='https://jaeumzhrdayuyqhemhyk.supabase.co/functions/v1/cleanBin',
          headers:='{"Content-Type": "application/json", "Authorization": "Bearer" : "your_api_key"}'::jsonb,
          body:=concat('{"endPoint": "https://jaeumzhrdayuyqhemhyk.supabase.co", "apiKey": "your_api_key", "roleKey": "your_role_key"}')::jsonb
      ) as request_id;
    $$
  );
*/
////////////////////////////////////////////////////////



import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient, SupabaseClient } from 'https://cdn.skypack.dev/@supabase/supabase-js';

console.log("removeDelta from Functions!")

Deno.serve(async (req) => {
  // const { name } = await req.json()
  // const data = {
  //   message: `Hello ${name}!`,
  // }

  // return new Response(
  //   JSON.stringify(data),
  //   { headers: { "Content-Type": "application/json" } },
  // )

  try {
  //console.log("Request Method:", req.method);
  //console.log("Request URL:", req.url);

  // Headers 객체를 배열로 변환하여 출력
  const headersArray = [];
  for (const [key, value] of req.headers.entries()) {
    headersArray.push({ key, value });
  }
  //console.log("Request Headers:", JSON.stringify(headersArray));

  // CORS 처리
  if (req.method === "OPTIONS") {
    console.log("OPTIONS 요청 처리");
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        "Access-Control-Max-Age": "3600", // 1시간 동안 프리플라이트 요청 결과를 캐시
      },
    });
  }


  const { endPoint, apiKey, roleKey} = await req.json();
  console.log("removeDelta ");

  // Ensure the SQL query, endPoint, and apiKey are provided
  if (!endPoint || !apiKey || !roleKey) {
    return new Response(
      JSON.stringify({ error: "endPoint, or apiKey not provided" }),
      {
        status: 400,
        headers: {
          'Access-Control-Allow-Origin': '*',
          "Content-Type": "application/json"
        }
      },
    );
  }

  // Execute the SQL query using Supabase client
  //console.log("endPoint: ", endPoint);
  //console.log("apiKey: ", apiKey);
  //console.log("roleKey: ", roleKey);
  const supabase: SupabaseClient = createClient(endPoint, roleKey || apiKey);
  
  let oneMinuteAgoStr: string = _formatDate();
  let counter: number = 0;

  // Supabase에서 일정 시간이 경과한 데이터를 조회

  const { data, error } = await supabase
    .from('hycop_delta')
    .select('mid, updateTime')
    .lt('updateTime', oneMinuteAgoStr);

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 
        'Access-Control-Allow-Origin' : '*',
        "Content-Type": "application/json" } },
    );
  }

  if (data) {
    for (const row of data) {
      const { mid, updateTime } = row;
      counter++;

      // Supabase에서 데이터 삭제
      const { error: deleteError } = await supabase
        .from('hycop_delta')
        .delete()
        .eq('mid', mid);

      if (deleteError) {
        console.log(`skpark removed = ${mid} failed : ${deleteError.message}`);
        return new Response(
          JSON.stringify(deleteError.message),
          { status: 500, headers: { 
            'Access-Control-Allow-Origin': '*',
            "Content-Type": "application/json" } },
        );
      } else {
        console.log(`skpark removed = ${mid} succeed`);
      }
    }
  }

  console.log(`skpark listed(${oneMinuteAgoStr}) = ${counter}`);
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

})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/removeDelta' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

function _formatDate(): string {
  let now: Date = new Date();
  //const now: Date = new Date(now.getTime() + (60000 * 60 * 9) - 60000); // local time 으로 맞춰주기 위해. localTime 함수가 안먹는다. 이방법 뿐이다.
  const year: number = now.getFullYear();
  const month: string = String(now.getMonth() + 1).padStart(2, '0');
  const day: string = String(now.getDate()).padStart(2, '0');
  const hours: string = String(now.getHours()).padStart(2, '0');
  const minutes: string = String(now.getMinutes()).padStart(2, '0');
  const seconds: string = String(now.getSeconds()).padStart(2, '0');
  const milliseconds: string = String(now.getMilliseconds()).padStart(3, '0');

  console.log(`skpark now = ${year}-${month}-${day}T${hours}:${minutes}:${seconds}.${milliseconds}Z`);
  return `${year}-${month}-${day}T${hours}:${minutes}:${seconds}.${milliseconds}Z`;
}



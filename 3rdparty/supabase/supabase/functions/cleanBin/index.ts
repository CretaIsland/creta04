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
    'invoke-cleanBin-every-day',
    '0 1 * * *', -- every day at 1:00 AM
    $$
    select
      net.http_post(
          url:='https://jaeumzhrdayuyqhemhyk.supabase.co/functions/v1/cleanBin',
          headers:='{"Content-Type": "application/json", "Authorization": "Bearer" : ""}'::jsonb,
          body:=concat('{"endPoint": "https://jaeumzhrdayuyqhemhyk.supabase.co", "apiKey": "", "roleKey": ""}')::jsonb
      ) as request_id;
    $$
  );
*/
////////////////////////////////////////////////////////



import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient, SupabaseClient } from 'https://cdn.skypack.dev/@supabase/supabase-js';

console.log("cleanBin from Functions!");

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
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          "Access-Control-Max-Age": "3600", // 1시간 동안 프리플라이트 요청 결과를 캐시
        },
      });
    }

    console.log("executeSQL 1.1");

    const { endPoint, apiKey, roleKey} = await req.json();
    console.log("executeSQL 2");

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
    console.log("endPoint: ", endPoint);
    console.log("apiKey: ", apiKey);
    console.log("roleKey: ", roleKey);
    const supabase: SupabaseClient = createClient(endPoint, roleKey || apiKey);
    
    let counter: number = 0;

    // Supabase에서 일정 시간이 경과한 데이터를 조회
    const daysAgoString = _getDaysAgoAsString();

    counter += await _cleanBin(supabase,'creta_book',daysAgoString);
    counter += await _cleanBin(supabase,'creta_book_published',daysAgoString);
    counter += await _cleanBin(supabase,'creta_channel',daysAgoString);
    counter += await _cleanBin(supabase,'creta_comment',daysAgoString);
    counter += await _cleanBin(supabase,'creta_connected_user',daysAgoString);
    counter += await _cleanBin(supabase,'creta_contents',daysAgoString);
    counter += await _cleanBin(supabase,'creta_contents_published',daysAgoString);
    counter += await _cleanBin(supabase,'creta_depot',daysAgoString);
    counter += await _cleanBin(supabase,'creta_enterprise',daysAgoString);
    counter += await _cleanBin(supabase,'creta_favorites',daysAgoString);
    counter += await _cleanBin(supabase,'creta_filter',daysAgoString);
    counter += await _cleanBin(supabase,'creta_frame',daysAgoString);
    counter += await _cleanBin(supabase,'creta_frame_published',daysAgoString);
    counter += await _cleanBin(supabase,'creta_host',daysAgoString);
    counter += await _cleanBin(supabase,'creta_link',daysAgoString);
    counter += await _cleanBin(supabase,'creta_link_published',daysAgoString);
    counter += await _cleanBin(supabase,'creta_page',daysAgoString);
    counter += await _cleanBin(supabase,'creta_page_published',daysAgoString);
    counter += await _cleanBin(supabase,'creta_playlist',daysAgoString);
    counter += await _cleanBin(supabase,'creta_scrshot',daysAgoString);
    counter += await _cleanBin(supabase,'creta_subscription',daysAgoString);
    counter += await _cleanBin(supabase,'creta_team',daysAgoString);
    counter += await _cleanBin(supabase,'creta_template',daysAgoString);
    counter += await _cleanBin(supabase,'creta_user_property',daysAgoString);
    counter += await _cleanBin(supabase,'creta_watch_history',daysAgoString);

    if (counter === 0) {
      return new Response(
        JSON.stringify({ deleted: counter }),
        { status: 500, headers: { 
          'Access-Control-Allow-Origin' : '*',
          "Content-Type": "application/json" } },
      );
    }

    console.log("clean bean succeed : "  + counter);
    return new Response(
       JSON.stringify({ deleted: counter }),
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

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/cleanBin' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

function _getDaysAgoAsString(): string {
  const now = new Date();
  now.setDate(now.getDate() - 3);
  const retval = now.toISOString().replace(/\..+/, '.000Z');
  console.log(retval);
  return retval;
}

async function __cleanBin(supabase: SupabaseClient, collectionId: string, daysAgoString: string): Promise<{ status: number, message: string }> {
  console.log('skpark _deleteRecycleBin invoked ' + collectionId);
 
  // Supabase에서 일정 시간이 경과한 데이터를 한 번에 삭제
  const { data, error } = await supabase
    .from(collectionId)
    .delete()
    .eq('isRemoved', true)
    .lte('updateTime', daysAgoString);

  if (error) {
    console.log(`Error deleting data: ${error.message}`);
    return { status: 500, message: `Error deleting data: ${error.message}` };
  }

  //const totalDeleted = data.length;
  //console.log(`{result: ${collectionId} isRemoved deleted}`);
  return { status: 200, message: `{result: ${collectionId}  isRemoved deleted}` };
}

async function _cleanBin(supabase: SupabaseClient, collectionId: string, daysAgoString: string): Promise<number> {
  try {
    const result = await __cleanBin(supabase, collectionId, daysAgoString);
    if (result.status === 200) {
      console.log('Success:', result.message);
      return 1;
    } else {
      console.error('Error:', result.message);
      return 0;
    }
  } catch (error) {
    console.error('Exception:', error);
    return 0;
  }
}


<?php

return [
    'base_url' => env('ISLAMHOUSE_BASE_URL', 'https://api3.islamhouse.com/v3'),
    'api_key' => env('ISLAMHOUSE_API_KEY', 'paV29H2gm56kvLPy'),
    'timeout' => (int) env('ISLAMHOUSE_TIMEOUT', 90),
    'retry_times' => (int) env('ISLAMHOUSE_RETRY_TIMES', 2),
    'retry_sleep_ms' => (int) env('ISLAMHOUSE_RETRY_SLEEP_MS', 500),
    'import_memory_limit' => env('ISLAMHOUSE_IMPORT_MEMORY_LIMIT', '1024M'),
    'sync_memory_limit' => env('ISLAMHOUSE_SYNC_MEMORY_LIMIT', '1024M'),
    'sync_per_page' => (int) env('ISLAMHOUSE_SYNC_PER_PAGE', 100),
    'queue_worker_memory' => (int) env('ISLAMHOUSE_QUEUE_WORKER_MEMORY', 512),
];

<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Jobs\ProcessCategoryItemsJob;

class ImportAnaMuslimItems extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'import:ana-muslim-items {type} {language=ar}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Dispatches a queue job to fetch all items for a specific category type.';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $type = $this->argument('type');
        $language = $this->argument('language');

        $this->info("Dispatching import job for type: {$type}, language: {$language}");

        ProcessCategoryItemsJob::dispatch($type, 1, $language);

        $this->info("Job dispatched. Run 'php artisan queue:work' to process.");
    }
}


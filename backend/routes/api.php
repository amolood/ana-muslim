<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AzkarApiController;
use App\Http\Controllers\Api\HadithApiController;
use App\Http\Controllers\Api\IslamicContentController;
use App\Http\Controllers\Api\QuranRecitersApiController;
use App\Http\Controllers\Api\RamadanApiController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('islamic-content')->group(function () {
    Route::get('/types', [IslamicContentController::class, 'getTypes']);
    Route::get('/highlights', [IslamicContentController::class, 'getHighlights']);
    Route::get('/latest', [IslamicContentController::class, 'getLatest']);
    Route::get('/items/details/{id}', [IslamicContentController::class, 'getItemDetails']);
    Route::get('/items/{type}', [IslamicContentController::class, 'getItems']);
});

Route::prefix('hadith')->group(function () {
    // Legacy action-based endpoint used by the mobile app today.
    Route::get('/', [HadithApiController::class, 'legacy']);

    // REST-style endpoints for future integrations.
    Route::get('/collections', [HadithApiController::class, 'collections']);
    Route::get('/books/{collection}', [HadithApiController::class, 'books']);
    Route::get('/books/{collection}/{bookNumber}', [HadithApiController::class, 'book']);
    Route::get('/search/{collection}', [HadithApiController::class, 'search']);
    Route::get('/all/{collection}', [HadithApiController::class, 'all']);
});

Route::prefix('azkar')->group(function () {
    Route::get('/', [AzkarApiController::class, 'index']);
    Route::get('/categories', [AzkarApiController::class, 'categories']);
    Route::get('/items', [AzkarApiController::class, 'items']);
});

Route::get('/asma-allah', [AzkarApiController::class, 'asmaAllah']);

Route::prefix('quran')->group(function () {
    Route::get('/reciters', [QuranRecitersApiController::class, 'index']);
});

Route::prefix('ramadan')->group(function () {
    Route::get('/', [RamadanApiController::class, 'schedule']);
    Route::get('/today', [RamadanApiController::class, 'today']);
    Route::get('/cities', [RamadanApiController::class, 'cities']);
});

<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::middleware(['auth'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', [\App\Http\Controllers\Admin\DashboardController::class, 'index'])->name('dashboard');
    Route::resource('categories', \App\Http\Controllers\Admin\CategoryController::class);
    Route::resource('authors', \App\Http\Controllers\Admin\AuthorController::class);
    Route::resource('items', \App\Http\Controllers\Admin\ItemController::class);
    Route::resource('attachments', \App\Http\Controllers\Admin\AttachmentController::class);
    Route::get('hadith', [\App\Http\Controllers\Admin\HadithLibraryController::class, 'index'])->name('hadith.index');
    Route::get('hadith/{book}', [\App\Http\Controllers\Admin\HadithLibraryController::class, 'show'])->name('hadith.show');
});

Auth::routes();

Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');

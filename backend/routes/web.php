<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('landing');
});

Route::middleware(['auth'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', [\App\Http\Controllers\Admin\DashboardController::class, 'index'])->name('dashboard');
    Route::resource('categories', \App\Http\Controllers\Admin\CategoryController::class);
    Route::resource('authors', \App\Http\Controllers\Admin\AuthorController::class);
    Route::resource('items', \App\Http\Controllers\Admin\ItemController::class);
    Route::resource('attachments', \App\Http\Controllers\Admin\AttachmentController::class);
    Route::get('hadith', [\App\Http\Controllers\Admin\HadithLibraryController::class, 'index'])->name('hadith.index');
    Route::get('hadith/{book}', [\App\Http\Controllers\Admin\HadithLibraryController::class, 'show'])->name('hadith.show');
    Route::resource('reciters', \App\Http\Controllers\Admin\ReciterController::class);
    Route::resource('notifications', \App\Http\Controllers\Admin\NotificationController::class);
    Route::post('notifications/send', [\App\Http\Controllers\Admin\NotificationController::class, 'send'])->name('notifications.send');
    Route::get('settings', [\App\Http\Controllers\Admin\SettingController::class, 'index'])->name('settings.index');
    Route::post('settings', [\App\Http\Controllers\Admin\SettingController::class, 'update'])->name('settings.update');

    // Hisnmuslim Admin Routes
    Route::prefix('hisnmuslim')->name('hisnmuslim.')->group(function () {
        Route::get('/', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'index'])->name('index');
        Route::get('/chapter/{id}', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'show'])->name('show');
        Route::get('/chapter/{id}/edit', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'editChapter'])->name('chapter.edit');
        Route::put('/chapter/{id}', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'updateChapter'])->name('chapter.update');
        Route::delete('/chapter/{id}', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'deleteChapter'])->name('chapter.delete');
        Route::get('/chapter/create', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'createChapter'])->name('chapter.create');
        Route::post('/chapter', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'storeChapter'])->name('chapter.store');

        Route::get('/dua/{id}/edit', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'editDua'])->name('dua.edit');
        Route::put('/dua/{id}', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'updateDua'])->name('dua.update');
        Route::delete('/dua/{id}', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'deleteDua'])->name('dua.delete');
        Route::get('/chapter/{chapterId}/dua/create', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'createDua'])->name('dua.create');
        Route::post('/chapter/{chapterId}/dua', [\App\Http\Controllers\Admin\HisnmuslimAdminController::class, 'storeDua'])->name('dua.store');
    });
});

Auth::routes();

Route::get('/azkar', function () {
    return view('azkar');
})->name('azkar');

Route::get('/quran', function () {
    return view('quran');
})->name('quran');

Route::get('/privacy', function () {
    return view('privacy');
})->name('privacy');

Route::get('/quran-text', function () {
    return view('quran-text');
})->name('quran-text');

Route::get('/quran-premium', function () {
    return view('quran-premium');
})->name('quran-premium');

Route::get('/hisnmuslim', function () {
    return view('hisnmuslim');
})->name('hisnmuslim');

Route::get('/hisnmuslim/{id}', function ($id) {
    return view('hisnmuslim-chapter', ['chapterId' => $id]);
})->name('hisnmuslim.chapter');

Route::get('/terms', function () {
    return view('terms');
})->name('terms');

Route::get('/contact', function () {
    return view('contact');
})->name('contact');

Route::get('/faq', function () {
    return view('faq');
})->name('faq');

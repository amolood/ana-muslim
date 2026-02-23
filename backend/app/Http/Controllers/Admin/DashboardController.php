<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimItem;
use App\Models\AnaMuslimCategory;
use App\Models\AnaMuslimAuthor;
use App\Models\AnaMuslimAttachment;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class DashboardController extends Controller
{
    private const TYPE_LABELS = [
        'audio' => 'صوتيات',
        'audios' => 'صوتيات',
        'video' => 'مرئيات',
        'videos' => 'مرئيات',
        'book' => 'كتاب',
        'books' => 'كتب',
        'article' => 'مقال',
        'articles' => 'مقالات',
        'fatwa' => 'فتاوى',
        'fatwas' => 'فتاوى',
        'quran' => 'القرآن الكريم',
        'khotab' => 'خطب',
        'poster' => 'بطاقات',
        'apps' => 'تطبيقات',
        'app' => 'تطبيق',
        'fav' => 'مفضلات',
        'favorites' => 'مفضلات',
    ];

    public function index()
    {
        $itemsCount = AnaMuslimItem::count();
        $categoriesCount = AnaMuslimCategory::count();
        $authorsCount = AnaMuslimAuthor::count();
        $attachmentsCount = AnaMuslimAttachment::count();

        $itemsWithCategories = $this->countDistinct('ana_muslim_item_category', 'item_id');
        $itemsWithAuthors = $this->countDistinct('ana_muslim_item_author', 'item_id');
        $itemsWithAttachments = $this->countDistinct('ana_muslim_attachments', 'item_id');

        $typeDistribution = $this->buildItemDistribution(
            column: 'type',
            totalItems: $itemsCount,
            labelResolver: fn (string $key): string => $this->resolveTypeLabel($key)
        );

        $sourceLanguageDistribution = $this->buildItemDistribution(
            column: 'source_language',
            totalItems: $itemsCount,
            labelResolver: fn (string $key): string => $this->resolveLanguageLabel($key)
        );

        $translatedLanguageDistribution = $this->buildItemDistribution(
            column: 'translated_language',
            totalItems: $itemsCount,
            labelResolver: fn (string $key): string => $this->resolveLanguageLabel($key)
        );

        $topCategories = DB::table('ana_muslim_categories as c')
            ->leftJoin('ana_muslim_item_category as ic', 'c.id', '=', 'ic.category_id')
            ->select('c.id', 'c.title', 'c.language', 'c.items_count')
            ->selectRaw('COUNT(DISTINCT ic.item_id) as linked_items')
            ->groupBy('c.id', 'c.title', 'c.language', 'c.items_count')
            ->orderByDesc('linked_items')
            ->orderByDesc('c.items_count')
            ->limit(10)
            ->get()
            ->map(function ($row) use ($itemsCount): array {
                $linkedItems = (int) $row->linked_items;

                return [
                    'id' => (int) $row->id,
                    'title' => (string) $row->title,
                    'language' => $this->resolveLanguageLabel((string) ($row->language ?? 'unknown')),
                    'linked_items' => $linkedItems,
                    'share' => $itemsCount > 0 ? round(($linkedItems / $itemsCount) * 100, 1) : 0.0,
                ];
            });

        $topAuthors = DB::table('ana_muslim_authors as a')
            ->leftJoin('ana_muslim_item_author as ia', 'a.id', '=', 'ia.author_id')
            ->select('a.id', 'a.title', 'a.type')
            ->selectRaw('COUNT(DISTINCT ia.item_id) as linked_items')
            ->groupBy('a.id', 'a.title', 'a.type')
            ->orderByDesc('linked_items')
            ->limit(10)
            ->get()
            ->map(function ($row) use ($itemsCount): array {
                $linkedItems = (int) $row->linked_items;

                return [
                    'id' => (int) $row->id,
                    'title' => (string) $row->title,
                    'type' => $this->resolveTypeLabel((string) ($row->type ?? 'unknown')),
                    'linked_items' => $linkedItems,
                    'share' => $itemsCount > 0 ? round(($linkedItems / $itemsCount) * 100, 1) : 0.0,
                ];
            });

        $attachmentTypeDistribution = AnaMuslimAttachment::query()
            ->selectRaw("LOWER(COALESCE(NULLIF(TRIM(extension_type), ''), 'unknown')) as ext_key")
            ->selectRaw('COUNT(*) as total')
            ->groupBy('ext_key')
            ->orderByDesc('total')
            ->limit(8)
            ->get()
            ->map(function ($row) use ($attachmentsCount): array {
                $count = (int) $row->total;
                $key = (string) $row->ext_key;
                $label = $key === 'unknown' ? 'غير محدد' : strtoupper($key);

                return [
                    'key' => $key,
                    'label' => $label,
                    'count' => $count,
                    'share' => $attachmentsCount > 0 ? round(($count / $attachmentsCount) * 100, 1) : 0.0,
                ];
            });

        $apiHealth = $this->buildApiHealth();
        $queueHealth = $this->buildQueueHealth();
        $quranStats = $this->buildQuranStats();
        $metadataStats = $this->buildMetadataStats();

        $stats = [
            'items_count' => $itemsCount,
            'categories_count' => $categoriesCount,
            'authors_count' => $authorsCount,
            'attachments_count' => $attachmentsCount,
            'items_with_categories' => $itemsWithCategories,
            'items_with_authors' => $itemsWithAuthors,
            'items_with_attachments' => $itemsWithAttachments,
            'uncategorized_items' => max(0, $itemsCount - $itemsWithCategories),
            'unattributed_items' => max(0, $itemsCount - $itemsWithAuthors),
            'recent_items' => AnaMuslimItem::with('categories')->latest()->take(8)->get(),
            'type_distribution' => $typeDistribution,
            'source_language_distribution' => $sourceLanguageDistribution,
            'translated_language_distribution' => $translatedLanguageDistribution,
            'attachment_type_distribution' => $attachmentTypeDistribution,
            'top_categories' => $topCategories,
            'top_authors' => $topAuthors,
            'api_health' => $apiHealth,
            'queue_health' => $queueHealth,
            'quran_stats' => $quranStats,
            'metadata_stats' => $metadataStats,
            'last_content_update' => AnaMuslimItem::max('updated_at'),
        ];

        return view('admin.dashboard', compact('stats'));
    }

    private function buildItemDistribution(string $column, int $totalItems, callable $labelResolver): Collection
    {
        $allowedColumns = ['type', 'source_language', 'translated_language'];
        if (!in_array($column, $allowedColumns, true)) {
            return collect();
        }

        return AnaMuslimItem::query()
            ->selectRaw("LOWER(COALESCE(NULLIF(TRIM({$column}), ''), 'unknown')) as metric_key")
            ->selectRaw('COUNT(*) as total')
            ->groupBy('metric_key')
            ->orderByDesc('total')
            ->limit(10)
            ->get()
            ->map(function ($row) use ($totalItems, $labelResolver): array {
                $key = (string) $row->metric_key;
                $count = (int) $row->total;

                return [
                    'key' => $key,
                    'label' => $labelResolver($key),
                    'count' => $count,
                    'share' => $totalItems > 0 ? round(($count / $totalItems) * 100, 1) : 0.0,
                ];
            });
    }

    private function buildApiHealth(): array
    {
        if (!Schema::hasTable('islamhouse_endpoint_snapshots')) {
            return [
                'enabled' => false,
                'snapshots_total' => 0,
                'snapshots_success' => 0,
                'snapshots_failed' => 0,
                'success_rate' => 0.0,
                'last_fetched_at' => null,
                'failed_groups' => collect(),
                'recent_failures' => collect(),
            ];
        }

        $snapshotsTotal = (int) DB::table('islamhouse_endpoint_snapshots')->count();
        $snapshotsSuccess = (int) DB::table('islamhouse_endpoint_snapshots')
            ->whereBetween('status_code', [200, 299])
            ->count();
        $snapshotsFailed = (int) DB::table('islamhouse_endpoint_snapshots')
            ->where(function ($query): void {
                $query->whereNull('status_code')
                    ->orWhere('status_code', '>=', 400);
            })
            ->count();

        $failedGroups = DB::table('islamhouse_endpoint_snapshots')
            ->select('endpoint_group')
            ->selectRaw('COUNT(*) as total')
            ->where(function ($query): void {
                $query->whereNull('status_code')
                    ->orWhere('status_code', '>=', 400);
            })
            ->groupBy('endpoint_group')
            ->orderByDesc('total')
            ->limit(6)
            ->get()
            ->map(fn ($row): array => [
                'group' => trim((string) ($row->endpoint_group ?? '')) !== '' ? (string) $row->endpoint_group : 'General',
                'count' => (int) $row->total,
            ]);

        $recentFailures = DB::table('islamhouse_endpoint_snapshots')
            ->select('endpoint_group', 'endpoint_name', 'status_code', 'fetched_at', 'request_url')
            ->where(function ($query): void {
                $query->whereNull('status_code')
                    ->orWhere('status_code', '>=', 400);
            })
            ->orderByDesc('fetched_at')
            ->limit(8)
            ->get();

        return [
            'enabled' => true,
            'snapshots_total' => $snapshotsTotal,
            'snapshots_success' => $snapshotsSuccess,
            'snapshots_failed' => $snapshotsFailed,
            'success_rate' => $snapshotsTotal > 0 ? round(($snapshotsSuccess / $snapshotsTotal) * 100, 1) : 0.0,
            'last_fetched_at' => DB::table('islamhouse_endpoint_snapshots')->max('fetched_at'),
            'failed_groups' => $failedGroups,
            'recent_failures' => $recentFailures,
        ];
    }

    private function buildQueueHealth(): array
    {
        return [
            'jobs_table_exists' => Schema::hasTable('jobs'),
            'failed_jobs_table_exists' => Schema::hasTable('failed_jobs'),
            'pending' => Schema::hasTable('jobs') ? (int) DB::table('jobs')->count() : 0,
            'failed' => Schema::hasTable('failed_jobs') ? (int) DB::table('failed_jobs')->count() : 0,
            'last_failed_at' => Schema::hasTable('failed_jobs') ? DB::table('failed_jobs')->max('failed_at') : null,
        ];
    }

    private function buildQuranStats(): array
    {
        return [
            'enabled' => Schema::hasTable('islamhouse_quran_categories'),
            'categories' => $this->tableCount('islamhouse_quran_categories'),
            'authors' => $this->tableCount('islamhouse_quran_authors'),
            'recitations' => $this->tableCount('islamhouse_quran_recitations'),
            'suras' => $this->tableCount('islamhouse_quran_suras'),
            'category_author_links' => $this->tableCount('islamhouse_quran_category_author'),
            'author_recitation_links' => $this->tableCount('islamhouse_quran_author_recitation'),
            'sura_recitation_links' => $this->tableCount('islamhouse_quran_sura_recitation'),
        ];
    }

    private function buildMetadataStats(): Collection
    {
        $metadataTables = [
            'islamhouse_site_sections' => 'أقسام الواجهة',
            'islamhouse_languages' => 'لغات API',
            'islamhouse_language_terms' => 'مصطلحات الترجمة',
            'islamhouse_available_languages' => 'لغات متاحة حسب السياق',
            'islamhouse_available_types' => 'أنواع متاحة حسب السياق',
            'islamhouse_item_counts' => 'عدادات المواد',
            'islamhouse_footer_items' => 'روابط الفوتر',
        ];

        $rows = [];
        foreach ($metadataTables as $table => $label) {
            if (!Schema::hasTable($table)) {
                continue;
            }

            $rows[] = [
                'table' => $table,
                'label' => $label,
                'count' => (int) DB::table($table)->count(),
            ];
        }

        return collect($rows);
    }

    private function resolveTypeLabel(string $type): string
    {
        $normalized = strtolower(trim($type));

        if ($normalized === '' || $normalized === 'unknown') {
            return 'غير مصنف';
        }

        return self::TYPE_LABELS[$normalized] ?? $normalized;
    }

    private function resolveLanguageLabel(string $language): string
    {
        $normalized = strtolower(trim($language));

        if ($normalized === '' || $normalized === 'unknown') {
            return 'غير محدد';
        }

        return strtoupper($normalized);
    }

    private function countDistinct(string $table, string $column): int
    {
        if (!Schema::hasTable($table)) {
            return 0;
        }

        return (int) DB::table($table)->distinct()->count($column);
    }

    private function tableCount(string $table): int
    {
        if (!Schema::hasTable($table)) {
            return 0;
        }

        return (int) DB::table($table)->count();
    }
}

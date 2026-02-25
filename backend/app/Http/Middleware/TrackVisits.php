<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Models\AnaMuslimVisit;
use Jaybizzle\CrawlerDetect\CrawlerDetect;
use Stevebauman\Location\Facades\Location;

class TrackVisits
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Only track successful GET requests to web routes
        if ($request->method() !== 'GET' || $response->getStatusCode() !== 200 || $request->ajax()) {
            return $response;
        }

        // Exclude admin routes
        if ($request->is('admin*')) {
            return $response;
        }

        // Detect and exclude bots
        $crawlerDetect = new CrawlerDetect;
        if ($crawlerDetect->isCrawler($request->userAgent())) {
            return $response;
        }

        try {
            $ip = $request->ip();
            $url = $request->fullUrl();
            $location = Location::get($ip);

            // Determine if unique (simple logic: once per IP per 24h)
            $isUnique = !AnaMuslimVisit::where('ip', $ip)
                ->where('created_at', '>=', now()->subDay())
                ->exists();

            $userAgent = $request->userAgent();
            $agentInfo = $this->parseUserAgent($userAgent);

            AnaMuslimVisit::create([
                'ip' => $ip,
                'url' => $url,
                'country' => $location->countryName ?? 'Unknown',
                'city' => $location->cityName ?? 'Unknown',
                'browser' => $agentInfo['browser'],
                'os' => $agentInfo['os'],
                'device' => $agentInfo['device'],
                'referer' => $request->header('referer'),
                'is_unique' => $isUnique,
            ]);
        } catch (\Exception $e) {
            // Silently fail to not break the user experience
            \Log::error('Visit tracking error: ' . $e->getMessage());
        }

        return $response;
    }

    private function parseUserAgent($userAgent)
    {
        $browser = 'Unknown';
        $os = 'Unknown';
        $device = 'desktop';

        if (stripos($userAgent, 'mobile') !== false) {
            $device = 'mobile';
        } elseif (stripos($userAgent, 'tablet') !== false) {
            $device = 'tablet';
        }

        // Simple parsing for demo/common cases
        if (stripos($userAgent, 'Firefox') !== false) {
            $browser = 'Firefox';
        } elseif (stripos($userAgent, 'Chrome') !== false) {
            $browser = 'Chrome';
        } elseif (stripos($userAgent, 'Safari') !== false) {
            $browser = 'Safari';
        } elseif (stripos($userAgent, 'Edge') !== false) {
            $browser = 'Edge';
        }

        if (stripos($userAgent, 'Windows') !== false) {
            $os = 'Windows';
        } elseif (stripos($userAgent, 'Android') !== false) {
            $os = 'Android';
        } elseif (stripos($userAgent, 'iPhone') !== false || stripos($userAgent, 'iPad') !== false) {
            $os = 'iOS';
        } elseif (stripos($userAgent, 'Macintosh') !== false) {
            $os = 'MacOS';
        } elseif (stripos($userAgent, 'Linux') !== false) {
            $os = 'Linux';
        }

        return compact('browser', 'os', 'device');
    }
}

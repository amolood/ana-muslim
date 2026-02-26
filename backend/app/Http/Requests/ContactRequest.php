<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Http;

class ContactRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'whatsapp' => ['nullable', 'string', 'max:20'],
            'subject' => ['required', 'string', 'in:bug,feature,support,feedback,other'],
            'message' => ['required', 'string', 'max:5000'],
            'cf-turnstile-response' => ['required', 'string'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'name.required' => 'الاسم مطلوب.',
            'email.required' => 'البريد الإلكتروني مطلوب.',
            'email.email' => 'يرجى إدخال بريد إلكتروني صحيح.',
            'phone.max' => 'رقم الهاتف يجب ألا يتجاوز 20 حرفاً.',
            'whatsapp.max' => 'رقم الواتساب يجب ألا يتجاوز 20 حرفاً.',
            'subject.required' => 'الموضوع مطلوب.',
            'subject.in' => 'الموضوع المحدد غير صالح.',
            'message.required' => 'الرسالة مطلوبة.',
            'message.max' => 'الرسالة يجب ألا تتجاوز 5000 حرف.',
            'cf-turnstile-response.required' => 'يرجى إكمال التحقق من أنك لست روبوت.',
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            if ($validator->errors()->has('cf-turnstile-response')) {
                return;
            }

            $token = $this->input('cf-turnstile-response');
            $secret = config('services.turnstile.secret');

            if (! $secret) {
                return;
            }

            $response = Http::asForm()->post('https://challenges.cloudflare.com/turnstile/v0/siteverify', [
                'secret' => $secret,
                'response' => $token,
                'remoteip' => $this->ip(),
            ]);

            if (! $response->successful() || ! $response->json('success')) {
                $validator->errors()->add('cf-turnstile-response', 'فشل التحقق. يرجى المحاولة مرة أخرى.');
            }
        });
    }
}

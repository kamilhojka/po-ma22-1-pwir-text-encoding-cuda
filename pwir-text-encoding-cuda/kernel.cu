
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <windows.h>
#include <chrono>
#include <thread>
#include <vector>
#include <omp.h>
#include <stdio.h>

#define MAX_TAB_SIZE 1000 
using namespace std;

void ShowIntroInformation(HANDLE hConsole);
void SetSortOption(HANDLE hConsole, int& sort);
void SetText(HANDLE hConsole, char text[MAX_TAB_SIZE]);
void SetKeyValue(HANDLE hConsole, int& key);
void SetDelayValue(HANDLE hConsole, int& delay);
void SetDisplayValue(HANDLE hConsole, int& display);
void SetRepeatValue(HANDLE hConsole, int& repeat);
void RunEncodeTextMethod(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display);
void RunEncodeTextMethodParallel(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display);
void RunEncodeTextMethodParallelOpenMP(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display);
void RunEncodeTextMethodParallelCuda(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display);
void RunDecodeTextMethod(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display);
void RunDecodeTextMethodParallel(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display);
void RunDecodeTextMethodParallelOpenMP(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display);
void RunDecodeTextMethodParallelCuda(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display);

int main()
{
	setlocale(LC_CTYPE, "Polish");
	char text[MAX_TAB_SIZE], tmptext[MAX_TAB_SIZE];
	int sort, key, delay, display, repeat;
	HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
	ShowIntroInformation(hConsole);
	while (true)
	{
		SetSortOption(hConsole, sort);
		cin.ignore(MAX_TAB_SIZE, '\n');
		SetText(hConsole, text);
		SetKeyValue(hConsole, key);
		SetDelayValue(hConsole, delay);
		SetDisplayValue(hConsole, display);
		if (sort == 1)
		{
			memcpy(tmptext, text, MAX_TAB_SIZE);
			RunEncodeTextMethod(hConsole, tmptext, key, delay, display);
			memcpy(tmptext, text, MAX_TAB_SIZE);
			RunEncodeTextMethodParallel(hConsole, tmptext, key, delay, display);
			memcpy(tmptext, text, MAX_TAB_SIZE);
			RunEncodeTextMethodParallelOpenMP(hConsole, tmptext, key, delay, display);
			memcpy(tmptext, text, MAX_TAB_SIZE);
			RunEncodeTextMethodParallelCuda(hConsole, tmptext, key, delay, display);
		}
		else if (sort == 2)
		{
			memcpy(tmptext, text, MAX_TAB_SIZE);
			RunDecodeTextMethod(hConsole, tmptext, key, delay, display);
			memcpy(tmptext, text, MAX_TAB_SIZE);
			RunDecodeTextMethodParallel(hConsole, tmptext, key, delay, display);
			memcpy(tmptext, text, MAX_TAB_SIZE);
			RunDecodeTextMethodParallelOpenMP(hConsole, tmptext, key, delay, display);
			memcpy(tmptext, text, MAX_TAB_SIZE);
			RunDecodeTextMethodParallelCuda(hConsole, tmptext, key, delay, display);
		}
		SetRepeatValue(hConsole, repeat);
		if (repeat == 0) break;
	}
}

void ShowIntroInformation(HANDLE hConsole)
{
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n\n  PROGRAMOWANIE WSPÓŁBIEŻNE I ROZPROSZONE 21/22L\n  Rozwiązanie równania różniczkowego zwyczajnego\n  Autor programu: ";
	SetConsoleTextAttribute(hConsole, 15);
	cout << "Kamil Hojka -- 97632\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	cout << "\n";
	SetConsoleTextAttribute(hConsole, 15);
}

void SetSortOption(HANDLE hConsole, int& sort)
{
	SetConsoleTextAttribute(hConsole, 14);
	cout << "\n -> Opcje:";
	cout << "\n --> [1] Szyfrowanie (Encode)";
	cout << "\n --> [2] Deszyfrowanie (Decode)";
	while (true) {
		SetConsoleTextAttribute(hConsole, 14);
		cout << "\n --> Wybierz spośród dostępnych opcji: ";
		SetConsoleTextAttribute(hConsole, 15);
		cin >> sort;
		if (cin.good() && (sort == 1 || sort == 2)) break;
		SetConsoleTextAttribute(hConsole, 4);
		cout << "    ! Wartość musi być liczbą równą jednej z dostępnych opcji\n";
		SetConsoleTextAttribute(hConsole, 15);
		cin.clear();
		cin.ignore();
	}
}

void SetText(HANDLE hConsole, char text[MAX_TAB_SIZE])
{
	while (true) {
		SetConsoleTextAttribute(hConsole, 14);
		cout << "\n -> Wprowadź tekst ";
		SetConsoleTextAttribute(hConsole, 4);
		cout << "[Limit znaków: 1000]: ";
		SetConsoleTextAttribute(hConsole, 15);
		cin.getline(text, MAX_TAB_SIZE);
		if (cin.good()) break;
		SetConsoleTextAttribute(hConsole, 4);
		cout << "    ! Wystąpił błąd podczas wprowadzenia tekstu, spróbuj jeszcze raz\n";
		SetConsoleTextAttribute(hConsole, 15);
		cin.clear();
		cin.ignore();
	}
}

void SetKeyValue(HANDLE hConsole, int& key)
{
	while (true) {
		SetConsoleTextAttribute(hConsole, 14);
		cout << "\n -> Podaj wartość klucza? [-26, ..., 26]: ";
		SetConsoleTextAttribute(hConsole, 15);
		cin >> key;
		if (cin.good() && (key <= 26 && key >= -26)) break;
		SetConsoleTextAttribute(hConsole, 4);
		cout << "    ! Wartość klucza musi mieścić się w przedziale [-26, ..., 26]\n";
		SetConsoleTextAttribute(hConsole, 15);
		cin.clear();
		cin.ignore();
	}
}

void SetDelayValue(HANDLE hConsole, int& delay)
{
	while (true) {
		SetConsoleTextAttribute(hConsole, 14);
		cout << "\n -> Podaj opóźnienie? [ms]: ";
		SetConsoleTextAttribute(hConsole, 15);
		cin >> delay;
		if (cin.good() && delay >= 0) break;
		SetConsoleTextAttribute(hConsole, 4);
		cout << "    ! Wartość opóźnienia musi być liczbą naturalną {0, 1, 2, ...}\n";
		SetConsoleTextAttribute(hConsole, 15);
		cin.clear();
		cin.ignore();
	}
}

void SetDisplayValue(HANDLE hConsole, int& display)
{
	while (true) {
		SetConsoleTextAttribute(hConsole, 14);
		cout << "\n -> Czy wyświetlić wynik? [1/0]: ";
		SetConsoleTextAttribute(hConsole, 15);
		cin >> display;
		if (cin.good() && (display == 0 || display == 1)) break;
		SetConsoleTextAttribute(hConsole, 4);
		cout << "    ! Wartość musi być liczbą 0 lub 1\n";
		SetConsoleTextAttribute(hConsole, 15);
		cin.clear();
		cin.ignore();
	}
}

void SetRepeatValue(HANDLE hConsole, int& repeat)
{
	while (true) {
		SetConsoleTextAttribute(hConsole, 14);
		cout << "\n -> Czy powtórzyć program? [1/0]: ";
		SetConsoleTextAttribute(hConsole, 15);
		cin >> repeat;
		if (cin.good() && (repeat == 0 || repeat == 1)) break;
		SetConsoleTextAttribute(hConsole, 4);
		cout << "    ! Wartość musi być liczbą 0 lub 1\n";
		SetConsoleTextAttribute(hConsole, 15);
		cin.clear();
		cin.ignore();
	}
}

void EncodeText(char text[MAX_TAB_SIZE], int key, int delay, int i)
{
	bool isGood = false;
	char a, z;
	this_thread::sleep_for(std::chrono::milliseconds(delay));
	if (text[i] >= 'a' && text[i] <= 'z') {
		a = 'a', z = 'z';
		isGood = true;
	}
	else if (text[i] >= 'A' && text[i] <= 'Z') {
		a = 'A', z = 'Z';
		isGood = true;
	}

	if (isGood) {
		if (key >= 0)
		{
			if (text[i] + key <= z) text[i] += key;
			else text[i] = text[i] + key - 26;
		}
		else {
			if (text[i] + key >= a) text[i] += key;
			else text[i] = text[i] + key + 26;
		}
	}
}

void RunEncodeTextMethod(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display)
{
	cout << "\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n ---> Sekwencyjne szyfrowanie tekstu - Szyfr Cezara\n";
	SetConsoleTextAttribute(hConsole, 15);
	auto begin = chrono::high_resolution_clock::now();
	for (int i = 0; i < strlen(text); i++)
	{
		EncodeText(text, key, delay, i);
	}
	auto end = chrono::high_resolution_clock::now();
	auto elapsed = chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();
	if (display)
	{
		cout << "\n Zaszyfrowany tekst: ";
		SetConsoleTextAttribute(hConsole, 14);
		cout << text;
		SetConsoleTextAttribute(hConsole, 15);
	}
	cout << "\n\n Zmierzony czas: " << elapsed << " ms\n";
}

void RunEncodeTextMethodParallel(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display)
{
	cout << "\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n ---> Równoległe szyfrowanie tekstu za pomocą thread - Szyfr Cezara\n";
	SetConsoleTextAttribute(hConsole, 15);
	auto begin = chrono::high_resolution_clock::now();
	vector<thread> threads(strlen(text));
	for (int i = 0; i < threads.size(); i++)
	{
		threads[i] = thread(EncodeText, text, key, delay, i);
	}
	for (auto& thread : threads)
	{
		thread.join();
	}
	auto end = chrono::high_resolution_clock::now();
	auto elapsed = chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();
	if (display)
	{
		cout << "\n Zaszyfrowany tekst: ";
		SetConsoleTextAttribute(hConsole, 14);
		cout << text;
		SetConsoleTextAttribute(hConsole, 15);
	}
	cout << "\n\n Zmierzony czas: " << elapsed << " ms\n";
}

void RunEncodeTextMethodParallelOpenMP(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display)
{
	cout << "\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n ---> Równoległe szyfrowanie tekstu za pomocą OpenMP - Szyfr Cezara\n";
	SetConsoleTextAttribute(hConsole, 15);
	auto begin = chrono::high_resolution_clock::now();
#pragma omp parallel for schedule(static, 1)
	for (int i = 0; i < strlen(text); i++)
	{
		EncodeText(text, key, delay, i);
	}
	auto end = chrono::high_resolution_clock::now();
	auto elapsed = chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();
	if (display)
	{
		cout << "\n Zaszyfrowany tekst: ";
		SetConsoleTextAttribute(hConsole, 14);
		cout << text;
		SetConsoleTextAttribute(hConsole, 15);
	}
	cout << "\n\n Zmierzony czas: " << elapsed << " ms\n";
}

void DecodeText(char text[MAX_TAB_SIZE], int key, int delay, int i)
{
	bool isGood = false;
	char a, z;
	this_thread::sleep_for(std::chrono::milliseconds(delay));
	if (text[i] >= 'a' && text[i] <= 'z') {
		a = 'a', z = 'z';
		isGood = true;
	}
	else if (text[i] >= 'A' && text[i] <= 'Z') {
		a = 'A', z = 'Z';
		isGood = true;
	}

	if (isGood) {
		if (key >= 0)
		{
			if (text[i] - key >= a) text[i] -= key;
			else text[i] = text[i] - key + 26;
		}
		else {
			if (text[i] - key <= z) text[i] -= key;
			else text[i] = text[i] - key - 26;
		}
	}
}

void RunDecodeTextMethod(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display)
{
	cout << "\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n ---> Sekwencyjne deszyfrowanie tekstu - Szyfr Cezara\n";
	SetConsoleTextAttribute(hConsole, 15);
	auto begin = chrono::high_resolution_clock::now();
	for (int i = 0; i < strlen(text); i++)
	{
		DecodeText(text, key, delay, i);
	}
	auto end = chrono::high_resolution_clock::now();
	auto elapsed = chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();
	if (display)
	{
		cout << "\n Zdeaszyfrowany tekst: ";
		SetConsoleTextAttribute(hConsole, 14);
		cout << text;
		SetConsoleTextAttribute(hConsole, 15);
	}
	cout << "\n\n Zmierzony czas: " << elapsed << " ms\n";
}

void RunDecodeTextMethodParallel(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display)
{
	cout << "\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n ---> Równoległe deszyfrowanie tekstu za pomocą thread - Szyfr Cezara\n";
	SetConsoleTextAttribute(hConsole, 15);
	auto begin = chrono::high_resolution_clock::now();
	vector<thread> threads(strlen(text));
	for (int i = 0; i < threads.size(); i++)
	{
		threads[i] = thread(DecodeText, text, key, delay, i);
	}
	for (auto& thread : threads)
	{
		thread.join();
	}
	auto end = chrono::high_resolution_clock::now();
	auto elapsed = chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();
	if (display)
	{
		cout << "\n Zdeaszyfrowany tekst: ";
		SetConsoleTextAttribute(hConsole, 14);
		cout << text;
		SetConsoleTextAttribute(hConsole, 15);
	}
	cout << "\n\n Zmierzony czas: " << elapsed << " ms\n";
}

void RunDecodeTextMethodParallelOpenMP(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display)
{
	cout << "\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n ---> Równoległe deszyfrowanie tekstu za pomocą OpenMP - Szyfr Cezara\n";
	SetConsoleTextAttribute(hConsole, 15);
	auto begin = chrono::high_resolution_clock::now();
#pragma omp parallel for schedule(static, 1)
	for (int i = 0; i < strlen(text); i++)
	{
		DecodeText(text, key, delay, i);
	}
	auto end = chrono::high_resolution_clock::now();
	auto elapsed = chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();
	if (display)
	{
		cout << "\n Zdeszyfrowany tekst: ";
		SetConsoleTextAttribute(hConsole, 14);
		cout << text;
		SetConsoleTextAttribute(hConsole, 15);
	}
	cout << "\n\n Zmierzony czas: " << elapsed << " ms\n";
}

__global__ void EncodeTextKernel(char* text, int N, int key, int delay)
{
	int i = threadIdx.x;
	if (i < N) {
		bool isGood = false;
		char a, z;
		/*clock_t start = clock();
		clock_t now;
		for (;;) {
			now = clock();
			clock_t cycles = now > start ? now - start : now + (0xffffffff - start);
			if (cycles >= delay * 1000000) {
				break;
			}
		}*/
		if (text[i] >= 'a' && text[i] <= 'z') {
			a = 'a', z = 'z';
			isGood = true;
		}
		else if (text[i] >= 'A' && text[i] <= 'Z') {
			a = 'A', z = 'Z';
			isGood = true;
		}

		if (isGood) {
			if (key >= 0)
			{
				if (text[i] + key <= z) text[i] += key;
				else text[i] = text[i] + key - 26;
			}
			else {
				if (text[i] + key >= a) text[i] += key;
				else text[i] = text[i] + key + 26;
			}
		}
	}
}

void RunEncodeTextMethodParallelCuda(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display)
{
	cout << "\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n ---> Równoległe szyfrowanie tekstu za pomocą CUDA - Szyfr Cezara\n";
	SetConsoleTextAttribute(hConsole, 15);
	char* dev_text;
	int N = strlen(text);
	cudaMalloc((void**)&dev_text, N * sizeof(char));
	cudaMemcpy(dev_text, text, N * sizeof(char), cudaMemcpyHostToDevice);
	dim3 grid_size(1);
	dim3 block_size(N);
	cudaEvent_t start, end;
	float elapsed;
	cudaEventCreate(&start);
	cudaEventCreate(&end);
	cudaEventRecord(start, 0);
	this_thread::sleep_for(std::chrono::milliseconds(delay));
	EncodeTextKernel << <grid_size, block_size >> > (dev_text, N, key, delay);
	cudaEventRecord(end, 0);
	cudaEventSynchronize(end);
	cudaEventElapsedTime(&elapsed, start, end);
	cudaMemcpy(text, dev_text, N * sizeof(char), cudaMemcpyDeviceToHost);
	if (display)
	{
		cout << "\n Zaszyfrowany tekst: ";
		SetConsoleTextAttribute(hConsole, 14);
		cout << text;
		SetConsoleTextAttribute(hConsole, 15);
	}
	cout << "\n\n Zmierzony czas: " << elapsed << " ms\n";
	cudaEventDestroy(start);
	cudaEventDestroy(end);
	cudaFree(dev_text);
}

__global__ void DecodeTextKernel(char* text, int N, int key, int delay)
{
	int i = threadIdx.x;
	if (i < N) {
		bool isGood = false;
		char a, z;
		/*clock_t start = clock();
		clock_t now;
		for (;;) {
			now = clock();
			clock_t cycles = now > start ? now - start : now + (0xffffffff - start);
			if (cycles >= delay * 1000000) {
				break;
			}
		}*/
		if (text[i] >= 'a' && text[i] <= 'z') {
			a = 'a', z = 'z';
			isGood = true;
		}
		else if (text[i] >= 'A' && text[i] <= 'Z') {
			a = 'A', z = 'Z';
			isGood = true;
		}

		if (isGood) {
			if (key >= 0)
			{
				if (text[i] - key >= a) text[i] -= key;
				else text[i] = text[i] - key + 26;
			}
			else {
				if (text[i] - key <= z) text[i] -= key;
				else text[i] = text[i] - key - 26;
			}
		}
	}
}

void RunDecodeTextMethodParallelCuda(HANDLE hConsole, char text[MAX_TAB_SIZE], int key, int delay, int display)
{
	cout << "\n\n";
	SetConsoleTextAttribute(hConsole, 11);
	for (int i = 0; i < 70; i++) cout << '*';
	SetConsoleTextAttribute(hConsole, 3);
	cout << "\n ---> Równoległe deszyfrowanie tekstu za pomocą CUDA - Szyfr Cezara\n";
	SetConsoleTextAttribute(hConsole, 15);
	char* dev_text;
	int N = strlen(text);
	cudaMalloc((void**)&dev_text, N * sizeof(char));
	cudaMemcpy(dev_text, text, N * sizeof(char), cudaMemcpyHostToDevice);
	dim3 grid_size(1);
	dim3 block_size(N);
	cudaEvent_t start, end;
	float elapsed;
	cudaEventCreate(&start);
	cudaEventCreate(&end);
	cudaEventRecord(start, 0);
	DecodeTextKernel << <grid_size, block_size >> > (dev_text, N, key, delay);
	cudaEventRecord(end, 0);
	cudaEventSynchronize(end);
	cudaEventElapsedTime(&elapsed, start, end);
	cudaMemcpy(text, dev_text, N * sizeof(char), cudaMemcpyDeviceToHost);
	if (display)
	{
		cout << "\n Zdeszyfrowany tekst: ";
		SetConsoleTextAttribute(hConsole, 14);
		cout << text;
		SetConsoleTextAttribute(hConsole, 15);
	}
	cout << "\n\n Zmierzony czas: " << elapsed << " ms\n";
	cudaEventDestroy(start);
	cudaEventDestroy(end);
	cudaFree(dev_text);
}
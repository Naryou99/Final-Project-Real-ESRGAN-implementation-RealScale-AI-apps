# RealScale AI APPS - AI Image Upscaler With Real-ESRGAN

<p align="center">
  <img src="https://raw.githubusercontent.com/Naryou99/Final-Project-Real-ESRGAN-implementation-RealScale-AI-apps/main/assets/demo%20app.gif" alt="Demo Aplikasi RealScale AI" width="300"/>
</p>

Aplikasi mobile android yang dikembangkan menggunakan Flutter dengan dukungan backend berbasis Python (FastAPI) untuk meningkatkan kualitas gambar menggunakan model Real-ESRGAN yang canggih. Proyek ini menampilkan integrasi lengkap dari model kecerdasan buatan berbasis PyTorch ke dalam aplikasi mobile modern, mulai dari backend hingga antarmuka pengguna.

---

## Table of Contents
* [English Version](#english-version-)
  * [Project Overview](#project-overview-)
  * [Core Features](#core-features-)
  * [How to Run Locally (Detailed Setup)](#how-to-run-locally-detailed-setup-)
    * [Prerequisites](#prerequisites-)
    * [Step 1: Project & Code Setup](#step-1-project--code-setup-)
    * [Step 2: Download AI Models](#step-2-download-ai-models-)
    * [Step 3: Python Environment Setup](#step-3-python-environment-setup-)
    * [Step 4: Run the Backend API Server](#step-4-run-the-backend-api-server-)
    * [Step 5: Run the Frontend Flutter App](#step-5-run-the-frontend-flutter-app-)
  * [Project Outcome](#project-outcome-)
  * [Acknowledgements](#acknowledgements-)
* [Versi Bahasa Indonesia](#versi-bahasa-indonesia-)
  * [Ringkasan Proyek](#ringkasan-proyek-)
  * [Fitur Unggulan](#fitur-unggulan-)
  * [Cara Menjalankan Proyek Secara Lokal (Setup Detail)](#cara-menjalankan-proyek-secara-lokal-setup-detail-)
    * [Prasyarat](#prasyarat-)
    * [Langkah 1: Persiapan Proyek & Kode](#langkah-1-persiapan-proyek--kode-)
    * [Langkah 2: Unduh Model AI](#langkah-2-unduh-model-ai-)
    * [Langkah 3: Setup Lingkungan Python](#langkah-3-setup-lingkungan-python-)
    * [Langkah 4: Jalankan Server Backend API](#langkah-4-jalankan-server-backend-api-)
    * [Langkah 5: Jalankan Aplikasi Frontend Flutter](#langkah-5-jalankan-aplikasi-frontend-flutter-)
  * [Hasil Akhir Proyek](#hasil-akhir-proyek-)
  * [Penghargaan](#penghargaan-)

---

## English Version 🇬🇧

### Project Overview 
This project consists of two main components:

1.  **Backend**: A robust API server built with Python and FastAPI. It handles image uploads, processes them using the Real-ESRGAN model (with GFPGAN support for face restoration), and returns the upscaled image. The logic is optimized to load models into memory once at startup for high performance.
2.  **Frontend**: A cross-platform mobile application built with Flutter. It provides a clean and modern user interface for selecting images, configuring upscale options, and interactively comparing the 'before' and 'after' results with a custom-built slider.

### Core Features 
* **AI-Powered Upscaling**: Enhances image resolution using the Real-ESRGAN model.
* **Face Enhancement**: An optional toggle to activate GFPGAN for significantly improved facial details.
* **Versatile Scaling Options**: Supports 2x, 4x, 6x scaling, plus intelligent 2K and 4K resolution targeting that respects image orientation (portrait/landscape).
* **Format Selection**: Users can choose between PNG, JPG, or an AUTO mode that matches the input format.
* **Modern & Responsive UI**:
    * Clean interface with the Poppins font family.
    * Light & Dark Mode support with a custom-themed toggle switch.
    * An interactive comparison slider to view results.

---

### How to Run Locally (Detailed Setup) 
Follow these steps sequentially to set up and run the entire project from scratch on your local machine.

#### Prerequisites 
* Python 3.10 or newer installed.
* Flutter SDK installed.
* Git installed.
* An NVIDIA GPU with up-to-date CUDA drivers is highly recommended for performance.

#### Step 1: Project & Code Setup 
First, we will create the main project structure and clone the necessary AI repository.

```bash
# 1. Navigate to your main development directory
cd path/to/your/development/folder

# 2. Create the main project folder and enter it
mkdir RealScaleAI_Project
cd RealScaleAI_Project

# 3. Create the backend folder and enter it
mkdir backend
cd backend

# 4. Clone the Real-ESRGAN repository into a folder named 'realesrgan'
git clone [https://github.com/xinntao/Real-ESRGAN.git](https://github.com/xinntao/Real-ESRGAN.git) realesrgan
```
After this, you will have a `backend/realesrgan/` folder. Place your `main.py`, `requirements.txt`, etc., inside the `backend` folder.

#### Step 2: Download AI Models 
The AI models are not included in the repository and must be downloaded manually.

1.  **Create destination folders** if they don't exist:
    * `backend/realesrgan/weights/`
    * `backend/gfpgan/weights/`

2.  **Download the following files** and place them in the correct folders:

    * **File:** `RealESRGAN_x4plus.pth`
        * **Download Link:** [https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth)
        * **Destination:** `backend/realesrgan/weights/`

    * **File:** `GFPGANv1.3.pth`
        * **Download Link:** [https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth](https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth)
        * **Destination:** `backend/gfpgan/weights/`

    * **File:** `detection_Resnet50_Final.pth`
        * **Download Link:** [https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth](https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth)
        * **Destination:** `backend/gfpgan/weights/`

    * **File:** `parsing_parsenet.pth`
        * **Download Link:** [https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth](https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth)
        * **Destination:** `backend/gfpgan/weights/`

#### Step 3: Python Environment Setup 
We will create a virtual environment and install all required packages. Make sure your terminal is still inside the **`backend`** folder.

```bash
# 1. Create the virtual environment (only done once)
python -m venv venv

# 2. Activate the virtual environment
# On Windows (cmd): venv\Scripts\activate

# 3. (Recommended) Upgrade pip, Python's package installer
python -m pip install --upgrade pip

# 4. Install dependencies for FastAPI and the AI models.
#    This includes PyTorch, so ensure you have a stable internet connection.
pip install -r requirements.txt
pip install -r realesrgan/requirements.txt
```

#### Step 4: Run the Backend API Server 
Now your backend is ready. Start the server.

```bash
# Make sure your venv is active: (venv) should be at the start of your prompt
# Make sure you are in the 'backend' folder

# Run the Uvicorn server
uvicorn main:app --host 0.0.0.0 --port=8000
```
**Important:** Leave this terminal running.

#### Step 5: Run the Frontend Flutter App 
Open a **new, separate** terminal.

```bash
# 1. Navigate to your main project directory
cd path/to/your/RealScaleAI_Project

# 2. Navigate into the frontend folder
cd frontend

# 3. Ensure the API URL in lib/image_service.dart is correct
# For local testing with an Android Emulator: "[http://10.0.2.2:8000/upscale](http://10.0.2.2:8000/upscale)"
# For local testing with a physical phone: "http://[YOUR-PC-IP-ADDRESS]:8000/upscale"

# 4. Get Flutter packages
flutter pub get

# 5. Run the application
flutter run
```

---
### Project Outcome 
This project successfully demonstrates the integration of a PyTorch AI model with a Flutter mobile application via a backend API. This architecture allows for heavy AI processing to be offloaded to a server, keeping the client-side application lightweight and responsive.

### Acknowledgements 
This project heavily utilizes the powerful **Real-ESRGAN** model. All credit for the AI model and its core implementation goes to Xintao Wang and the original contributors.

* **Official Real-ESRGAN Repository:** [https://github.com/xinntao/Real-ESRGAN.git](https://github.com/xinntao/Real-ESRGAN.git)

<br>

---

## Versi Bahasa Indonesia 🇮🇩

### Ringkasan Proyek 
Proyek ini terdiri dari dua komponen utama:

1.  **Backend**: Sebuah API server yang dibuat dengan Python dan FastAPI. Bagian ini bertanggung jawab untuk menerima unggahan gambar, memprosesnya dengan model Real-ESRGAN (dengan dukungan GFPGAN untuk perbaikan wajah), dan mengirimkan kembali gambar hasil upscale. Logikanya dioptimalkan untuk memuat model ke memori sekali saja saat startup untuk performa tinggi.
2.  **Frontend**: Sebuah aplikasi mobile cross-platform yang dibuat dengan Flutter. Aplikasi ini menyediakan antarmuka bagi pengguna untuk memilih gambar, mengatur opsi upscale, dan secara interaktif membandingkan hasil "sebelum" dan "sesudah" dengan slider kustom.

### Fitur Unggulan 
* **Upscaling dengan AI**: Meningkatkan resolusi gambar dengan model Real-ESRGAN.
* **Perbaikan Wajah**: Opsi untuk mengaktifkan GFPGAN agar kualitas wajah pada gambar menjadi lebih baik.
* **Berbagai Skala**: Mendukung upscale 2x, 4x, 6x, serta penyesuaian ke resolusi 2K dan 4K yang cerdas (mendeteksi orientasi potret/lanskap).
* **Pilihan Format**: Pengguna bisa memilih output dalam format PNG, JPG, atau mode AUTO yang mengikuti format asli.
* **UI Modern & Responsif**:
    * Tampilan bersih dengan font Poppins.
    * Dukungan Mode Terang & Gelap dengan tombol switch kustom.
    * Slider perbandingan interaktif untuk melihat hasil.
    * Notifikasi elegan yang tidak mengganggu untuk setiap aksi pengguna.

---

### Cara Menjalankan Proyek Secara Lokal (Setup Detail) 
Ikuti langkah-langkah ini secara berurutan untuk menyiapkan dan menjalankan keseluruhan proyek dari awal di komputer lokal Anda.

#### Prasyarat 
* Python 3.10 atau lebih baru terinstal.
* Flutter SDK terinstal.
* Git terinstal.
* GPU NVIDIA dengan driver CUDA terbaru (sangat direkomendasikan untuk performa).

#### Langkah 1: Persiapan Proyek & Kode 
Pertama, kita akan membuat struktur proyek utama dan men-clone repositori AI yang dibutuhkan.

```bash
# 1. Arahkan ke direktori pengembangan utama Anda
cd D:\Development 2

# 2. Buat folder proyek utama dan masuk ke dalamnya
mkdir RealScaleAI_Project
cd RealScaleAI_Project

# 3. Buat folder backend dan masuk ke dalamnya
mkdir backend
cd backend

# 4. Clone repositori Real-ESRGAN ke dalam folder bernama 'realesrgan'
git clone [https://github.com/xinntao/Real-ESRGAN.git](https://github.com/xinntao/Real-ESRGAN.git) realesrgan
```
Setelah ini, Anda akan memiliki folder `backend/realesrgan/`. Letakkan file `main.py`, `requirements.txt`, dll., di dalam folder `backend`.

#### Langkah 2: Unduh Model AI 
Model AI tidak termasuk dalam repositori dan harus diunduh secara manual.

1.  **Buat folder tujuan** jika belum ada:
    * `backend/realesrgan/weights/`
    * `backend/gfpgan/weights/`

2.  **Unduh file-file berikut** dan letakkan di folder yang benar:

    * **File:** `RealESRGAN_x4plus.pth`
        * **Link Unduh:** [https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth)
        * **Tujuan:** `backend/realesrgan/weights/`

    * **File:** `GFPGANv1.3.pth`
        * **Link Unduh:** [https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth](https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth)
        * **Tujuan:** `backend/gfpgan/weights/`

    * **File:** `detection_Resnet50_Final.pth`
        * **Link Unduh:** [https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth](https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth)
        * **Tujuan:** `backend/gfpgan/weights/`

    * **File:** `parsing_parsenet.pth`
        * **Link Unduh:** [https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth](https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth)
        * **Tujuan:** `backend/gfpgan/weights/`

#### Langkah 3: Setup Lingkungan Python 
Kita akan membuat lingkungan virtual dan menginstal semua paket yang dibutuhkan. Pastikan terminal Anda masih berada di dalam folder **`backend`**.

```bash
# 1. Buat lingkungan virtual (cukup lakukan sekali)
python -m venv venv

# 2. Aktifkan lingkungan virtual
# Di Windows (cmd): venv\Scripts\activate

# 3. (Direkomendasikan) Upgrade pip, penginstal paket Python
python -m pip install --upgrade pip

# 4. Instal dependensi untuk server FastAPI dan model AI.
#    Proses ini akan mengunduh PyTorch, pastikan koneksi internet stabil.
pip install -r requirements.txt
pip install -r realesrgan/requirements.txt
```

#### Langkah 4: Jalankan Server Backend API 
Sekarang backend Anda sudah siap. Nyalakan servernya.

```bash
# Pastikan venv Anda aktif: (venv) akan muncul di awal prompt
# Pastikan Anda berada di folder 'backend'

# Jalankan server Uvicorn
uvicorn main:app --host 0.0.0.0 --port=8000
```
**Penting:** Biarkan terminal ini tetap berjalan.

#### Langkah 5: Jalankan Aplikasi Frontend Flutter 
Buka terminal **baru** yang terpisah.

```bash
# 1. Masuk ke direktori root proyek Anda
cd path/to/your/RealScaleAI_Project

# 2. Masuk ke folder frontend
cd frontend

# 3. Pastikan URL API di lib/image_service.dart sudah benar
# Untuk tes lokal dengan Emulator Android: "[http://10.0.2.2:8000/upscale](http://10.0.2.2:8000/upscale)"
# Untuk tes lokal dengan HP fisik: "http://[IP-LOKAL-ANDA]:8000/upscale"

# 4. Ambil semua paket Flutter
flutter pub get

# 5. Jalankan aplikasi
flutter run
```

---
### Hasil Akhir Proyek 
Proyek ini berhasil membuktikan integrasi antara model AI PyTorch dengan aplikasi mobile Flutter melalui sebuah backend API. Arsitektur ini memungkinkan pemrosesan AI yang berat dialihkan ke server, sehingga aplikasi di sisi pengguna tetap ringan dan responsif.

### Credit dan Terimakasih
Proyek ini sangat bergantung pada model **Real-ESRGAN** yang luar biasa. Seluruh kredit untuk model AI dan implementasi intinya ditujukan kepada Xintao Wang dan para kontributor aslinya.

* **Repositori Resmi Real-ESRGAN:** [https://github.com/xinntao/Real-ESRGAN.git](https://github.com/xinntao/Real-ESRGAN.git)

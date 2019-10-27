This is the software for the Transparency Toolkit OCR server. It receives data
from the document upload form, OCRs the documents, and saves the results.

1. Install the following packages:
* graphicsmagick
* poppler-data
* poppler-utils
* ghostscript
* tesseract-ocr
* pdftk
* libreoffice
* openjdk-8-jdk
* openjdk-8-jre
* libcurl3
* libcurl3-gnutls
* libcurl4-openssl-dev
* libmagic-dev

2. Install the following gems:
* mimemagic
* docsplit
* curb
* ruby filemagic
* pry
* mail
* listen
* rubyzip

3. Install Apache Tika server by downloading the .jar from
https://tika.apache.org/download.html

4. Start Tika by running: java -jar tika-server-1.18.jar

5. Optionally: Install ABBYY. This is not free software, but has higher
quality OCR for some file types. Images and image-style PDFs as well as
office documents that fail OCR with Tika will default to using ABBYY if it is
installed. A license for the command line version can be purchased at
https://www.ocr4linux.com/en:pricing:start. The OCR server will default to
Tesseract if ABBYY is not installed.

6. Setup and start https://github.com/TransparencyToolkit/DocUpload
Documents need to be uploaded for the rest to work.

7. Set the following environment variables:

  * OCR_IN_PATH: The path for documents and metadata to input
  * OCR_OUT_PATH: The path for documents to output
  * PROJECT_INDEX: The index name in elastic.

8. In this directory (for the OCRServer), run: ruby run_ocr.rb
It will then listen for new documents in OCR_IN.
This must be started BEFORE documents are uploaded.


Note: To run on an existing directory, set inotify_works = false in input_output/load_files.rb

This is the software for the Transparency Toolkit OCR server. It receives data
from the document upload form, OCRs the documents, and sends the results to
DocManager via an index server.

1. Install the following packages:
* graphicsmagick
* poppler-data
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
* doc_integrity_check
* mimemagic
* docsplit
* curb
* filemagic
* sinatra
* pry
* mail

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

7. In config.ru, set the gpg_recipient ID to the key ID for the index server
running on the same machine as DocManager. Set the gpg_signer as the key ID on
this machine.

8. In config.ru, set the indexserver_url to the URL of the index server
running on the same machine as DocManager.

9. In this directory (for the OCRServer), run: rackup config.ru -p 9393

10. Upload documents with the separate upload form app. They should be saved in
the raw_documents folder. The OCRed text of the documents will be stored in
raw_documents/text and sent to the UDP server, which sends them to DocManager
for indexing.


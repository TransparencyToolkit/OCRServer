This is the software for the Transparency Toolkit OCR server. It receives data
from the document upload form via UDP, OCRs the documents, and sends the
results to Catalyst.

1. Install the following packages:
* graphicsmagick
* poppler-data
* ghostscript
* tesseract
* pdftk
* libreoffice
* openjdk-8-jdk
* openjdk-8-jre
* libcurl3
* libcurl3-gnutls
* libcurl4-openssl-dev

2. Install the following gems:
* doc_integrity_check
* mimemagic
* docsplit
* curb

3. Install Apache Tika server by downloading the .jar from
https://tika.apache.org/download.html

4. Start Tika by running: java -jar tika-server-1.17.jar

5. Setup and start https://github.com/TransparencyToolkit/DocUpload

6. In this directory (for the OCRServer), run: rackup config.ru

During testing on one machine, you may need to ensure it runs on a port other
than 9292 (as that is the default port the upload form sets on). To do this,
simply add -p #### to the end of the call. In deployment this will not matter
because the upload form and OCR server will be on separate machines.

7. Upload documents with the separate upload form app. They should be saved in
the raw_documents folder. The OCRed text of the documents will be stored in
raw_documents/text.


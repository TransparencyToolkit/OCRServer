This is the software for the Transparency Toolkit OCR server. It receives data
from the document upload form via UDP, OCRs the documents, and sends the
results to Catalyst. 

1. Ensure you have doc_integrity_check installed

2. Setup and start https://github.com/TransparencyToolkit/DocUpload

3. In this directory, run: rackup config.ru

During testing on one machine, you may need to ensure it runs on a port other
than 9292 (as that is the default port the upload form sets on). To do this,
simply add -p #### to the end of the call. In deployment this will not matter
because the upload form and OCR server will be on separate machines.

4. Upload documents with the separate upload form app. They should be saved in
the raw_documents folder.


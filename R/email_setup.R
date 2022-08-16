# Email Setup Snippet
require(rstudioapi)

email_setup = function() {
  rstudioapi::insertText("
require(RDCOMClient)
OutApp <- COMCreate('Outlook.Application')
outMail = OutApp$CreateItem(0)
outMail[['To']] = 'name@domain.com;'
outMail[['subject']] = 'Email Subject'
outMail[['HTMLbody']] = 'Body of the email can be <b>HTML</b>'
outMail[['Attachments']]$Add('PATH/TO/FILE.xlsx')
outMail$Send()"
  )
}

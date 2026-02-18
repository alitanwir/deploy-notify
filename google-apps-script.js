// DeployNotify Google Apps Script Backend

function doPost(e) {
  try {
    var sheetId = "YOUR_SHEET_ID"; // <-- Replace with your Google Sheet ID
    var sheet = SpreadsheetApp.openById(sheetId).getActiveSheet();

    var data = JSON.parse(e.postData.contents);
    var timestamp = data.timestamp || new Date().toISOString();
    var user = data.user || "";
    var targets = (data.targets || []).join(", ");
    var gitBranch = data.git_branch || "";
    var gitCommit = data.git_commit || "";

    // Append to sheet
    sheet.appendRow([timestamp, user, targets, gitBranch, gitCommit]);

    // Send email to one or more recipients (comma-separated)
    // Example: "user1@example.com,user2@example.com"
    var emails = "YOUR_EMAIL@example.com"; // <-- Replace with one or more emails, comma-separated
    var subject = "🚀 Deployment Notification";
    var htmlBody =
      "<b>Deployment Notification</b><br><ul>" +
      "<li><b>Time:</b> " +
      timestamp +
      "</li>" +
      "<li><b>User:</b> " +
      user +
      "</li>" +
      "<li><b>Targets:</b> " +
      targets +
      "</li>" +
      "<li><b>Git Branch:</b> " +
      gitBranch +
      "</li>" +
      "<li><b>Commit:</b> " +
      gitCommit +
      "</li>" +
      "</ul>";

    MailApp.sendEmail({
      to: emails,
      subject: subject,
      htmlBody: htmlBody,
    });

    return ContentService.createTextOutput(
      JSON.stringify({ status: "ok" }),
    ).setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService.createTextOutput(
      JSON.stringify({ status: "error", message: err.message }),
    ).setMimeType(ContentService.MimeType.JSON);
  }
}

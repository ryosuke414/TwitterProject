// Message bean
package bean;

import java.time.LocalDateTime;

public class Message {
    private int messageId;
    private int fromUserId;
    private int toUserId;
    private String content;
    private LocalDateTime sentAt;

    private String fromHandle;  // 表示用
    private String toHandle;    // 表示用

    // Getters and setters
    public int getMessageId() { return messageId; }
    public void setMessageId(int messageId) { this.messageId = messageId; }

    public int getFromUserId() { return fromUserId; }
    public void setFromUserId(int fromUserId) { this.fromUserId = fromUserId; }

    public int getToUserId() { return toUserId; }
    public void setToUserId(int toUserId) { this.toUserId = toUserId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) { this.sentAt = sentAt; }

    public String getFromHandle() { return fromHandle; }
    public void setFromHandle(String fromHandle) { this.fromHandle = fromHandle; }

    public String getToHandle() { return toHandle; }
    public void setToHandle(String toHandle) { this.toHandle = toHandle; }
}

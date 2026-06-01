package vn.edu.fpt.enums;

public enum LessonModerationStatus {
    PENDING("pending"), AUTO_FLAGGED("auto_flagged"), CLEAN("clean"), APPROVED("approved"), REJECTED("rejected");

    private final String value;
    LessonModerationStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static LessonModerationStatus fromValue(String value) {
        for (LessonModerationStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown LessonModerationStatus: " + value);
    }
}

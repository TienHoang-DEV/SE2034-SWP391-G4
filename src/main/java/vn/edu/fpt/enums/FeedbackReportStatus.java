package vn.edu.fpt.enums;

public enum FeedbackReportStatus {
    PENDING("pending"), RESOLVED("resolved");

    private final String value;
    FeedbackReportStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static FeedbackReportStatus fromValue(String value) {
        for (FeedbackReportStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown FeedbackReportStatus: " + value);
    }
}

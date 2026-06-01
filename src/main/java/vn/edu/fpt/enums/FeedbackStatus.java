package vn.edu.fpt.enums;

public enum FeedbackStatus {
    VISIBLE("visible"), HIDDEN("hidden"), VIOLATION("violation");

    private final String value;
    FeedbackStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static FeedbackStatus fromValue(String value) {
        for (FeedbackStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown FeedbackStatus: " + value);
    }
}

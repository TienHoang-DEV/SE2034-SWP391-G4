package vn.edu.fpt.enums;

public enum CourseStatus {
    DRAFT("draft"), PENDING("pending"), PUBLISHED("published"), REJECTED("rejected"), HIDDEN("hidden");

    private final String value;
    CourseStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static CourseStatus fromValue(String value) {
        for (CourseStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown CourseStatus: " + value);
    }
}

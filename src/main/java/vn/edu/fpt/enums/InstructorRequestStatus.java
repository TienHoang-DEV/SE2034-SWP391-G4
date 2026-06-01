package vn.edu.fpt.enums;

public enum InstructorRequestStatus {
    PENDING("pending"), APPROVED("approved"), REJECTED("rejected"), BLOCKED("blocked");

    private final String value;
    InstructorRequestStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static InstructorRequestStatus fromValue(String value) {
        for (InstructorRequestStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown InstructorRequestStatus: " + value);
    }
}

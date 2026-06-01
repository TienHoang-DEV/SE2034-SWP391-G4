package vn.edu.fpt.enums;

public enum UserStatus {
    ACTIVE("active"), BANNED("banned"), PENDING("pending");

    private final String value;
    UserStatus(String value) { this.value = value; }
    public String getValue() { return value; }
    public static UserStatus fromValue(String value) {
        for (UserStatus s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown UserStatus: " + value);
    }
}

package vn.edu.fpt.enums;

public enum RoleType {
    ADMIN("admin"),
    MANAGER("manager"),
    INSTRUCTOR("instructor"),
    LEARNER("learner");

    private final String value;

    RoleType(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public static RoleType fromValue(String value) {
        for (RoleType r : values()) {
            if (r.value.equals(value)) {
                return r;
            }
        }
        throw new IllegalArgumentException("Unknown RoleType: " + value);
    }
}

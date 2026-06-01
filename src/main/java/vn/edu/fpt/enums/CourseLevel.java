package vn.edu.fpt.enums;

public enum CourseLevel {
    BEGINNER("beginner"), INTERMEDIATE("intermediate"), ADVANCED("advanced");

    private final String value;
    CourseLevel(String value) { this.value = value; }
    public String getValue() { return value; }
    public static CourseLevel fromValue(String value) {
        for (CourseLevel s : values()) if (s.value.equals(value)) return s;
        throw new IllegalArgumentException("Unknown CourseLevel: " + value);
    }
}

package vn.edu.fpt.exception;

/**
 * Thrown when a requested course is not found.
 */
public class CourseNotFoundException extends ApplicationException {

    private static final long serialVersionUID = 1L;

    public CourseNotFoundException() {
        super();
    }

    public CourseNotFoundException(String message) {
        super(message);
    }

    public CourseNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }

    public CourseNotFoundException(Throwable cause) {
        super(cause);
    }
}


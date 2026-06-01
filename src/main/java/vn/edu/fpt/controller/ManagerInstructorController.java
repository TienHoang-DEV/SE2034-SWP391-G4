package vn.edu.fpt.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.fpt.entity.InstructorRequest;
import vn.edu.fpt.service.InstructorRequestService;

@Controller
@RequestMapping("/manager/instructor")
public class ManagerInstructorController {

    private final InstructorRequestService instructorRequestService;

    public ManagerInstructorController(InstructorRequestService instructorRequestService) {
        this.instructorRequestService = instructorRequestService;
    }

    @GetMapping("/list")
    public String listInstructorRequests(
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "") String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("id").descending());
        Page<InstructorRequest> requestPage = instructorRequestService.searchAndFilter(keyword, status, pageable);

        model.addAttribute("requestPage", requestPage);
        model.addAttribute("keyword", keyword);
        model.addAttribute("status", status);

        return "manager/approval-instructor/instructor-list";
    }
}

package vn.edu.fpt.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class Helloworld {

    @GetMapping("/")
    public String homePage() {
        return "home/home";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "auth/register";
    }

    @GetMapping("/index")
    public String indexPage() {
        return "index";
    }

}

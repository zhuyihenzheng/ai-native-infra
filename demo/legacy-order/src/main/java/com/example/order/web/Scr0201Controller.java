package com.example.order.web;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.example.order.blogic.BLogicResult;
import com.example.order.blogic.OrderSearchBLogic;
import com.example.order.entity.Order;
import com.example.order.form.Scr0201Form;

/**
 * SCR0201 受注一覧画面。ルーティングは画面ID単位（/scr0201/xxx）。
 * Controller は編成のみ。業務処理は BLogic を直接呼ぶ（Service層は無い）。
 */
@Controller
@RequestMapping("/scr0201")
public class Scr0201Controller {

    @Autowired
    private OrderSearchBLogic orderSearchBLogic;

    /** 初期表示 */
    @GetMapping("/init")
    public String init(@ModelAttribute("form") Scr0201Form form) {
        return "scr0201/index";
    }

    /** 検索実行 */
    @PostMapping("/search")
    public String search(@ModelAttribute("form") Scr0201Form form, Model model) {
        BLogicResult<List<Order>> result = orderSearchBLogic.execute(form);

        if (BLogicResult.STATUS_OK.equals(result.getStatus())) {
            model.addAttribute("orderList", result.getData());
        } else {
            model.addAttribute("messageId", result.getMessageId());
        }
        return "scr0201/index";
    }
}

package io.sevenseven.staking.aggregator.service.application.web

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController


@RestController
class HomeResource {

    @GetMapping("/")
    fun index(): String = "\"Hello World!\""

}

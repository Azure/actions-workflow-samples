package com.createcosmos.action;

import com.createcosmos.action.resource.App;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ActionApplication {

	public static void main(String[] args) {
		SpringApplication.run(ActionApplication.class, args);
		App exampleApp = new App();
		exampleApp.run();
	}

}

package com.ivolve.roadmap;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
public class RoadmapController {

    @GetMapping("/api/roadmap")
    public ResponseEntity<?> roadmap() {

        return ResponseEntity.ok(List.of(
            Map.of(
                "title", "OS",
                "description", "Learn Linux commands, processes, networking and shell scripting."
            ),
            Map.of(
                "title", "SCM",
                "description", "Learn Git workflows, branching, merging and collaboration."
            ),
            Map.of(
                "title", "Containerization",
                "description", "Learn container concepts, Docker images, containers, registries, networking and Docker Compose."
            ),
            Map.of(
                "title", "Container Orchestration",
                "description", "Learn Kubernetes concepts, Pods, Deployments, Services, ConfigMaps, Secrets, Ingress and cluster management."
            ),
            Map.of(
                "title", "CI/CD",
                "description", "Learn Jenkins, GitHub Actions and automated delivery via ArgoCD."
            ),
            Map.of(
                "title", "Cloud",
                "description", "Learn core AWS services, IAM, networking and EKS."
            ),
            Map.of(
                "title", "Infrastructure as Code",
                "description", "Learn Terraform, providers, resources, variables, modules and state management."
            ),
            Map.of(
                "title", "Configuration Management",
                "description", "Learn Ansible, playbooks, inventories, roles and automated server provisioning."
            )
        ));
    }
}

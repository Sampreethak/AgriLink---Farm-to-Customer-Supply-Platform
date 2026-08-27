package com.agrilink.controller;

import com.agrilink.entity.Return;
import com.agrilink.service.ReturnService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/returns")
@RequiredArgsConstructor
@Tag(name = "Returns", description = "Product return and refund management APIs")
public class ReturnController {

    private final ReturnService returnService;

    @GetMapping("/{returnId}")
    @Operation(summary = "Get a return request by ID")
    public ResponseEntity<Return> getReturn(@PathVariable UUID returnId) {
        return ResponseEntity.ok(returnService.findById(returnId));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get all returns for a customer")
    public ResponseEntity<Page<Return>> getCustomerReturns(
            @PathVariable UUID customerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(returnService.getCustomerReturns(customerId,
                PageRequest.of(page, size, Sort.by("returnDate").descending())));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "Get returns by status (admin)")
    public ResponseEntity<Page<Return>> getReturnsByStatus(
            @PathVariable String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(returnService.getReturnsByStatus(status,
                PageRequest.of(page, size, Sort.by("returnDate").descending())));
    }

    @PatchMapping("/{returnId}/approve")
    @Operation(summary = "Approve a return request (admin)")
    public ResponseEntity<Return> approveReturn(
            @PathVariable UUID returnId,
            @RequestParam UUID reviewedBy) {
        return ResponseEntity.ok(returnService.approveReturn(returnId, reviewedBy));
    }

    @PatchMapping("/{returnId}/reject")
    @Operation(summary = "Reject a return request (admin)")
    public ResponseEntity<Return> rejectReturn(
            @PathVariable UUID returnId,
            @RequestParam UUID reviewedBy) {
        return ResponseEntity.ok(returnService.rejectReturn(returnId, reviewedBy));
    }
}

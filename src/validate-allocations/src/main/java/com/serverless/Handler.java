package com.secretsanta;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.List;

class Allocation {
    private Participant participant;
    private Participant recipient;

    public Participant getParticipant() {
        return participant;
    }

    public void setParticipant(Participant participant) {
        this.participant = participant;
    }

    public Participant getRecipient() {
        return recipient;
    }

    public void setRecipient(Participant recipient) {
        this.recipient = recipient;
    }
}

class Allocations {
    private List<Allocation> allocations;

    public List<Allocation> getAllocations() {
        return allocations;
    }

    public void setAllocations(List<Allocation> allocations) {
        this.allocations = allocations;
    }
}

class Participant {
    private String name;
    private String email;
    private String number;
    private List<String> exclusions;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public List<String> getExclusions() {
        return exclusions;
    }

    public void setExclusions(List<String> exclusions) {
        this.exclusions = exclusions;
    }
}

public class Handler implements RequestHandler<Allocations, Allocations> {
    Gson gson = new GsonBuilder().setPrettyPrinting().create();

    @Override
    public Allocations handleRequest(Allocations event, Context context) {
        for (Allocation allocation: event.getAllocations()) {
            if (allocation.getParticipant().getName().equals(allocation.getRecipient().getName())) {
                throw new RuntimeException("Unable to allocate self");
            }

            for (String exclusion: allocation.getParticipant().getExclusions()) {
                if (allocation.getRecipient().getName().equals(exclusion)) {
                    throw new RuntimeException("Recipient excluded by participant");
                }
            }
        }

        return event;
    }
}

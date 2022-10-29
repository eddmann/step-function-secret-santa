using System.Text.Json;

[assembly:LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace ParseParticipants;

public class Request
{
    public string body { get; set; }
}

public class Participants
{
    public List<Participant> participants { get; set; }
}

public class Participant
{
    public string name { get; set; } = "";
    public string email { get; set; } = "";
    public string number { get; set; } = "";
    public List<string> exclusions { get; set; } = new List<string>();

    public static Participant From(string line)
    {
        string[] values = line.Split(',');

        Participant participant = new Participant();
        participant.name = values[0];
        participant.email = values[1];
        participant.number = values[2];
        participant.exclusions = values[3].Split(';').ToList();

        return participant;
    }
}

public class Handler
{
    public Participants Handle(Request request, ILambdaContext context)
    {
        var parsed = request.body
            .Split("\n")
            .Select(line => Participant.From(line))
            .ToList();

        return new Participants { participants = parsed };
    }
}

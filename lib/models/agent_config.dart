enum AgentType {
  research,
  market,
  clinical,
  safety,
  general
}

class AgentConfig {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final String iconAsset;
  final AgentType type;

  const AgentConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    this.iconAsset = 'assets/icons/default_agent.png',
    this.type = AgentType.general,
  });
}

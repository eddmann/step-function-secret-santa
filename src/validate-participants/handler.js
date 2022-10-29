'use strict';

module.exports.handle = async event => {
  if (!event.participants.length) {
    throw new Error('No participants present');
  }

  for (const participant of event.participants) {
    if (!participant.name) throw new Error('Missing participant name');
    if (!participant.number && !participant.email)
      throw new Error('Missing participant number or email');
    if (!Array.isArray(participant.exclusions)) throw new Error('Missing exclusions list');
  }

  return event;
};

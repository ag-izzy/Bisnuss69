const Discord = require('discord.js');
const client = new Discord.Client();

const GALORANTROLE = "719978451787972720"
const STREAMINGROLE = "721142930525519903"

client.on('presenceUpdate', (oldPresence, newPresence) => {

    if (!newPresence.member || !newPresence.member._roles){
        return
    }
    if (newPresence.member.id == "628755933366845451"){
        return
    }
    if (!newPresence.member._roles.includes(GALORANTROLE)){
        return;
    }


    console.log('Presence update for', newPresence.member.displayName)

    if (isUserStreaming(newPresence) && !newPresence.member._roles.includes(STREAMINGROLE)){
        onUserStartStreaming(newPresence.member)
    } else if (!isUserStreaming(newPresence) && newPresence.member._roles.includes(STREAMINGROLE)){
        onUserStopStreaming(newPresence.member);
    }
    
    // if ((!oldPresence || !isUserStreaming(oldPresence)) && isUserStreaming(newPresence)) {
    //     onUserStartStreaming(newPresence.member)
    // } else if ((!oldPresence || isUserStreaming(oldPresence)) && !isUserStreaming(newPresence)){
    //     onUserStopStreaming(newPresence.member)
    // }
});

/**
 * Checks if the user is streaming
 * @param {Discord.Presence} presence - A Discord presence object
 */
function isUserStreaming(presence) {
    const activities = presence.activities
    if (!activities || activities.length === 0) {
        return false; 
    }
//Loops over the activities status's to see what it is
    for (let index = 0; index < activities.length; index++) {
        const activity = activities[index];
        if (activity.type === "STREAMING")
            return true;
    }

    return false;
}

function onUserStartStreaming(member){
    console.log('Giving role to ', member.displayName)
    member.roles.add(STREAMINGROLE)
}
function onUserStopStreaming(member){
    console.log('Taking role from ', member.displayName)
    member.roles.remove(STREAMINGROLE)
}

const Utils = require("../../modules/utils.js");
const Embed = Utils.Embed;
const config = Utils.variables.config;
const request = require("request-promise");

module.exports = {
  name: "code",
  run: async (bot, message, args) => {
    request
      .post({
        uri: "",
        headers: {
          Authorization: config.Key,
        },
        json: true,
      })
      .then((res) => {
        message.channel.send(
          Embed({
            title: "Code",
            description:
              "Your code is ``" +
              res.code +
              "``. You can go to ---- to see if this is a legitimate copy of DTeam. This will also show you the owner of the copy.",
          })
        );
      });
  },
  description:
    "Users can use this to determine if you are using a legitimate copy of Corebot.",
  usage: "code",
  aliases: [],
};

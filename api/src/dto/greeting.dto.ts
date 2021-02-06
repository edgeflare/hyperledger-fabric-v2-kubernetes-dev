import { ApiProperty } from "@nestjs/swagger";
import { IsArray, IsString } from "class-validator";

export class GreetingDto {
  @IsString()
  @ApiProperty({
    description: 'Fabric App username',
    default: 'demouser1'
  })
  appUser: string;

  @IsString()
  @ApiProperty({
    description: 'Fabric Channel ID',
    default: 'allorgs'
  })
  channelId: string;

  @IsString()
  @ApiProperty({
    description: 'Chaincode name',
    default: 'key-value-chaincode'
  })
  contractName: string;

  @IsString()
  @ApiProperty({
    description: 'Chaincode function name. Options: create | read | update',
    default: 'create'
  })
  func: string;

  @IsArray()
  @ApiProperty({
    description: 'Fabric Chaincode function arguments. read function requires key argument, while create and update functions require both key and value',
    default: [],
    isArray: true
  })
  args: string;
}
